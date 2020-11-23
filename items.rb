require 'json'
require 'nokogiri'

# format
# name: [String] item name
# type: [String] item type
# power: [Number] item power
# effect1?: [Object] item effect
# - name: [String] effect name
# - lv: [Number] item effect level
# - reqlv?: [Number] required level for crafting
# range?: [Number] weapon range
# material?: [String] material of the equipment

$config = {
	root_dir: "../release",
   target_enos: [[370, 987, 1013], [730, 784]],
   nth: 18,
}

players = []

def sugoi_material(type)
   case type
   when '法衣'
      return 'すごい木材'
   when '装飾'
      return 'すごい石材'
   throw "missing sugoi: #{type}"
   end
end

def trace_material(nth, eno, equipment_name)
   exceptions = {'キングの駒' => '頭蓋骨', '青碧のペンダント' => '孔雀石'}
   return exceptions[equipment_name] if exceptions[equipment_name]
   throw "missing item: #{equipment_name}" if nth < 1

   fpath = "#{$config[:root_dir]}/result#{format('%02d', nth)}/result/k/now/r#{eno}.html"

   # <SPAN CLASS=Y3>ItemNo.19 浮草</SPAN> から法衣『<SPAN CLASS=Y3>草編み戦外套</SPAN>』を作製しました！<BR>
   # <A HREF="r730.html" TARGET=_blank>モドラ(730)</A> により <SPAN CLASS=Y3>ItemNo.34 葵</SPAN> から法衣『<SPAN CLASS=Y3>水葉のはごろも</SPAN>』を作製してもらいました！<BR>

   # <A HREF="r370.html" TARGET=_blank>ドレイク教授(370)</A> から <SPAN CLASS=Y3>浮草</SPAN> を受け取りました。<BR>
   # <A HREF="r370.html" TARGET=_blank>ドレイク教授(370)</A> から <SPAN CLASS=Y3>葵</SPAN> を手渡しされました。<BR>
   # ItemNo.25 アクティブスーツ を ItemNo.24 に持ち替えました。

	# ファイル読み込み
	doc = nil
   File.open(fpath, "r:utf-8:utf-8") do |file|
      file.each_line do |line|
         case line
         when /<SPAN CLASS=Y3>ItemNo\.\d+ (.+)<\/SPAN> から.*『<SPAN CLASS=Y3>(.+)<\/SPAN>』を作製しました！/
            return $1 if equipment_name == $2
         when /.* により <SPAN CLASS=Y3>ItemNo\.\d+ (.+)<\/SPAN> から.*『<SPAN CLASS=Y3>(.+)<\/SPAN>』を作製してもらいました！/
            return $1 if equipment_name == $2
         when /<A HREF=.* TARGET=_blank>.*\((\d+)\)<\/A> から <SPAN CLASS=Y3>(.+)<\/SPAN> を(受け取りました|手渡しされました)。/
            if equipment_name == $2
               if $1.to_i < eno
                  return trace_material(nth, $1.to_i, equipment_name)
               else
                  return trace_material(nth-1, $1.to_i, equipment_name)
               end
            end
         end
      end
      return trace_material(nth-1, eno, equipment_name)
	end
end

class Item
   # required fields
   attr_accessor :name, :type, :power
   attr_accessor :special
   # optional fields
   attr_accessor :effect1, :effect2, :effect3
   attr_accessor :effectlv1, :effectlv2, :effectlv3
   attr_accessor :reqlv1, :reqlv2, :reqlv3
   attr_accessor :range
   attr_accessor :material

   def material_like?
      ['素材', '食材'].include?(@type)
   end

   def equipment?
      !['素材', '食材', '料理'].include?(@type)
   end

   def self.from_row(row, nth, eno)
      item_type = row.children[2].content
      return nil if item_type.strip == ""

      ret = Item.new
      ret.name = row.children[1].content
      ret.type = row.children[2].content
      ret.power = row.children[3].content.to_i
      ret.special = !row.children[0].attribute('style').nil?
      if ret.equipment?
         ret.material = ret.name == 'すごい' ? sugoi_material(ret.type) : trace_material(nth, eno, ret.name)
      end
      if ret.material_like?
         STDERR.puts "ERR: #{row.children[4].content}" unless /［.*］([^\d]+)(\d+)\(LV(\d+)\)［.*］([^\d]+)(\d+)\(LV(\d+)\)［.*］([^\d]+)(\d+)\(LV(\d+)\)/.match(row.children[4].content)
         ret.effect1 = $1
         ret.effectlv1 = $2.to_i
         ret.reqlv1 = $3.to_i
         ret.effect2 = $4
         ret.effectlv2 = $5.to_i
         ret.reqlv2 = $6.to_i
         ret.effect3 = $7
         ret.effectlv3 = $8.to_i
         ret.reqlv3 = $9.to_i
      else
         if /([^\d]+)(\d+)/.match(row.children[4].content)
            ret.effect1 = $1
            ret.effectlv1 = $2.to_i
         end
         if /([^\d]+)(\d+)/.match(row.children[5].content)
            ret.effect2 = $1
            ret.effectlv2 = $2.to_i
         end
         if /([^\d]+)(\d+)/.match(row.children[6].content)
            ret.effect3 = $1
            ret.effectlv3 = $2.to_i
         end
         if /【射程(\d+)】/.match(row.children[7].content)
            ret.range = $1.to_i
         end
      end
      return ret
   end

   def to_object
      obj = {}
      obj[:name] = @name
      obj[:type] = @type
      obj[:power] = @power
      obj[:special] = @special
      obj[:range] = @range if @range
      obj[:effect1] = {name: @effect1, lv: @effectlv1} if @effect1
      obj[:effect1][:reqlv] = @reqlv1 if @reqlv1
      obj[:effect2] = {name: @effect2, lv: @effectlv2} if @effect2
      obj[:effect2][:reqlv] = @reqlv2 if @reqlv2
      obj[:effect3] = {name: @effect3, lv: @effectlv3} if @effect3
      obj[:effect3][:reqlv] = @reqlv3 if @reqlv3
      obj[:material] = @material if @material
      obj
   end
end

for eno in $config[:target_enos].flatten do
   fname = "r#{eno}.html"
   fpath = "#{$config[:root_dir]}/result#{format('%02d', $config[:nth])}/result/k/now/#{fname}"

	# ファイル読み込み
	doc = nil
	File.open(fpath, "r:utf-8:utf-8") do |file|
		doc = Nokogiri::HTML.parse(file)
	end

	# パース
   begin
      player = {
         eno: eno,
         ps: nil, # TODO
         name: nil, # TODO
         items: [],
         researches: {},
      }
      player[:name] = doc.search('.CNM').first.content
      player[:ps] = doc.search('.CIMGNM3').first.children[0].content.to_i
      item_list = doc.search('.Y870>table').first
      item_list.search('tr').each do |row|
         next if row.children[0].content == "No"
         item_no = row.children[0].content.to_i
         item = Item.from_row(row, $config[:nth], eno.to_i)
         player[:items][item_no - 1] = item&.to_object
      end
      players.push(player)
      research_list = doc.search('.Y870>table')[5]
      research_list.search('tr').each do |row|
         next if row.children[0].content == "［深度］スキル名"
         row.children.each do |child|
            if /^［ (\d) ］(.+)$/.match(child.content)
               lv = $1.to_i
               name = $2
               player[:researches][name] = lv
            end
         end
      end
	rescue => e
		STDERR.puts "error in #{fname}"
		raise e
	end
end

export = { players: players, teams: $config[:target_enos] }

puts "export const players = #{JSON.dump(export)}"
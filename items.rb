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

def convert_item_type(item_type)
   case item_type
   when '素材'
      return 'material'
   when '食材'
      return 'food'
   when '料理'
      return 'dish'
   else
      return 'equipment'
   end
end

config = {
	root_dir: "../release",
   target_enos: [370, 421, 730, 784, 987, 1013],
	dir_name: "result12",
}

players = []

class Item
   # required fields
   attr_accessor :name, :type, :power
   attr_accessor :special
   # optional fields
   attr_accessor :effect1, :effect2, :effect3
   attr_accessor :effectlv1, :effectlv2, :effectlv3
   attr_accessor :reqlv1, :reqlv2, :reqlv3
   attr_accessor :range

   def material_like?
      ['素材', '食材'].include?(@type)
   end

   def self.from_row(row)
      item_type = row.children[2].content
      return nil if item_type.strip == ""

      ret = Item.new
      ret.name = row.children[1].content
      ret.type = row.children[2].content
      ret.power = row.children[3].content.to_i
      ret.special = !row.children[0].attribute('style').nil?
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
      obj
   end
end

for eno in config[:target_enos] do
   fname = "r#{eno}.html"
   fpath = "#{config[:root_dir]}/#{config[:dir_name]}/result/k/now/#{fname}"

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
         items: []
      }
      player[:name] = doc.search('.CNM').first.content
      player[:ps] = doc.search('.CIMGNM3').first.children[0].content.to_i
      item_list = doc.search('.Y870>table').first
      item_list.search('tr').each do |row|
         next if row.children[0].content == "No"
         item_no = row.children[0].content.to_i
         item = Item.from_row(row)
         player[:items][item_no - 1] = item&.to_object
      end
      players.push(player)
	rescue => e
		STDERR.puts "error in #{fname}"
		raise e
	end
end

puts "export const players = #{JSON.dump(players)}"
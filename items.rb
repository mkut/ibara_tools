require 'json'
require 'nokogiri'

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
         item_name = row.children[1].content
         item_type = convert_item_type(row.children[2].content)
         special_item = !row.children[0].attribute('style').nil?
         player[:items][item_no - 1] = item_name.strip == "" ? nil : { name: item_name, type: item_type, special: special_item }
      end
      players.push(player)
	rescue => e
		STDERR.puts "error in #{fname}"
		raise e
	end
end

puts "export const players = #{JSON.dump(players)}"
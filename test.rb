# coding: utf-8

search_config = {
	:dir_name => "result03",
	
	# 0 => normal, 1 => is_battle
	:matcher =>  /r\d+b\d\.html/
}

players = []

for fname in Dir.foreach("#{search_config[:dir_name]}/result/k/now") do
	if search_config[:matcher].match(fname)
		File.open("#{search_config[:dir_name]}/result/k/now/#{fname}", "r:utf-8:utf-8") do |file|
			rangesref = nil
			file.each_line do |line|
				m = /<B CLASS=BAA\d>▼<I CLASS=F5>(.*)は.*で参戦！/.match(line)
				if m
					pl = {
						:name => m[1],
						:fname => fname,
						:ranges => []
					}
					rangesref = pl[:ranges]
					players.push(pl)
				end
				m = /【射程(\d)】／<SPAN STYLE="color:#CC3333;">特殊アイテム<\/SPAN>/.match(line)
				if m
					rangesref.push(m[1])
				end
			end
		end
	end
end
players.each do |pl|
	if pl[:ranges].size == 2 && pl[:ranges][0] != pl[:ranges][1]
		puts "#{pl[:fname]} #{pl[:name]} #{pl[:ranges][0]} #{pl[:ranges][1]}"
	end
end
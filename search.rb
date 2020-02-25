# coding: utf-8

search_config = {
	:env_name => "release",
	:dir_name => "result01",
	
	:matchers => [/BSS1.*ドレイン！/,/HK1.*守勢/,/防具：強さ/],
	:ng_matchers => [/HK1.*堅守/,/HK1.*攻勢/],
	
	# 0 => normal, 1 => is_battle
	:matcher =>  /r\d+b\d\.html/
}

root_dir = "../#{search_config[:env_name]}/#{search_config[:dir_name]}/result/k/now"

matched_eid = []

for fname in Dir.foreach(root_dir) do
	if search_config[:matcher].match(fname)
		File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
			matched = search_config[:matchers].map { |any| false }
			ng_matched = search_config[:ng_matchers].map { |any| false }
			file.each_line do |line|
				search_config[:matchers].each_with_index do |matcher, i|
					if matcher.match(line)
						matched[i] = true
					end
				end
				search_config[:ng_matchers].each_with_index do |matcher, i|
					if matcher.match(line)
						ng_matched[i] = true
					end
				end
			end
			if matched.all? && !ng_matched.any?
				matched_eid.push(fname)
			end
		end
	end
end

matched_eid.each do |eid|
	puts eid
end
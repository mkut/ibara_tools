# coding: utf-8

require 'json'

search_config = {
	root_dir: "../release",
	dir_name: "result#{ARGV[0]}",
	fname: "#{ARGV[1]}.json",
	# matcher: /(r1013b\d)\.html/,
}

fpath = "#{search_config[:root_dir]}/#{search_config[:dir_name]}/parsed/battle_actions/#{search_config[:fname]}"

result = Hash.new{|h,k| h[k] = []}

File.open(fpath, "r:utf-8:utf-8") do |file|
	game = JSON.load(file, nil, symbolize_names: true, create_additions: false)
	game[:events].select{|x| x[:type] == 'round_state'}.each do |state|
		state[:players].each do |player|
			result[player[:name]].push(player[:extra_action_gauge])
		end
	end
end

result.each do |name, extras|
	puts "#{name}: #{extras.map(&:to_s).join(' ')}"
end

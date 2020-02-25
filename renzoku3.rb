# coding: utf-8

require 'json'

search_config = {
	root_dir: "../release",
	dir_name: "result02",
	matcher: /(r\d+b1)\.json/,
}

root_dir = "#{search_config[:root_dir]}/#{search_config[:dir_name]}/parsed/battle_actions"

def calc(extras)
	ret = []
	for ag in 1..1000
		cur = 0
		ok = true
		for extra in extras
			break [] if extra[:ng]
			unless extra[:gauge] == cur.floor % 100 || extra[:gauge] == 100
				ok = false
				break
			end
			inc = extra[:inc_ag] || 0
			added = extra[:added_gauge] || 0
			cur += (ag * 0.1 * (1 + inc)) ** 0.8 * 1.8 + added
		end
		ret.push(ag) if ok
	end
	ret
end

def flatten_effect2(effect)
	ret = [effect]
	effect[:triggers]&.each do |trigger|
		ret += flatten_effect(trigger)
	end
	ret
end

def flatten_effect(ba)
	ret = []
	ba[:effects]&.each do |effect|
		ret += flatten_effect2(effect)
	end
	ba[:triggers]&.each do |trigger|
		ret += flatten_effect(trigger)
	end
	return ret
end

for fname in Dir.foreach(root_dir) do
	next unless search_config[:matcher].match(fname)

   File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
		game = JSON.load(file, nil, symbolize_names: true, create_additions: false)

		extras = {}
		prev_mods = {}
		game[:events].each do |event|
			if event[:type] == 'round_state'
				event[:players].each do |player|
					name = player[:name]
					extras[name] = [] unless extras[name]
					current_extra = {
						gauge: player[:extra_action_gauge]
					}
					if prev_mods[name]
						current_extra.merge!(prev_mods[name])
					end
					extras[name].push(current_extra)
					prev_mods[name] = {
						inc_ag: (player[:position] - 1) * 0.2
					}
				end
			elsif event[:type] == 'battle_action'
				flatten_effect(event).each do |effect|
					if ['inc_stat', 'dec_stat', 'up_stat', 'down_stat'].include?(effect[:type]) && effect[:stat] == 'AG'
						prev_mods[effect[:target]] && prev_mods[effect[:target]][:ng] = true
					elsif ['buff_stat', 'debuff_stat'].include?(effect[:type]) && effect[:stat] == 'AG'
						prev_mods[effect[:target]] && prev_mods[effect[:target]][:ng] = true
					elsif ['inc_stat', 'dec_stat'].include?(effect[:type]) && effect[:stat] == '連続行動ゲージ'
						prev_mods[effect[:target]] && prev_mods[effect[:target]][:ng] = true
					end
				end
			end
		end
		extras.each do |player, ex|
			ret = calc(ex)
			if ret.length == 1
				puts "#{fname}: #{player} AG=#{ret[0]}"
			end
		end
	end
end

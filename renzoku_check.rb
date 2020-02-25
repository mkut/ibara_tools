require 'json'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	versions: ["result02", "result02s00", "result02s01", "result03", "result03s00"],
	matcher: /(r\d+b\d)\.json/,
	# matcher: /(r1369b1)\.json/,
}

result = {}

search_config[:versions].each do |version|
	root_dir = "#{search_config[:root_dir]}/#{version}/parsed/battle_actions"
   for fname in Dir.foreach(root_dir) do
      next unless search_config[:matcher].match(fname)

      File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
         game = JSON.load(file, nil, symbolize_names: true, create_additions: false)

         # 名前が同じプレイヤーがいるものは除外
         next if game[:players].size != game[:players].map{|p| p[:name]}.uniq.size

         # p version, fname

         players = {}
         game[:players].each do |player|
            players[player[:name]] = player
         end

         sim = Simulator.new(version)

         game[:beginning_phase][:players].each {|player| sim.apply_player_join(player) }
         game[:beginning_phase][:equips]&.each {|equip| sim.apply_equip(equip) }
         game[:beginning_phase][:events]&.each {|event| sim.apply_event(event) }

         teams = {}

			renzoku = {}
			inc_renzoku = {}
			current_name = nil

         game[:events].each do |event|
				if event[:type] == 'round_state'
					if current_name
						player = sim.players[current_name]
						player.ag = 0 if player.buffs['凍結'] > 0 || player.buffs['麻痺'] > 0 || player.buffs['石化'] > 0
						ag = player.ag
						ag *= 0.8 + player.zone.position * 0.2 # 隊列補正
						ag *= player.stat_buffs['AG'] ? (1 + player.stat_buffs['AG'][:amount] * 0.01) : 1
						inc_renzoku[current_name] = (ag * 0.1) ** 0.8 * 1.8
						# puts "B name=#{current_name} AG=#{player.ag} 隊列=#{player.zone.position} 補正=#{player.stat_buffs['AG'] ? player.stat_buffs['AG'][:amount] : 0}"
					end
					current_name = nil
					event[:players]&.each do |player|
						name = player[:name]
						game_player = sim.players[name]
						if renzoku[name]
							renzoku[name] += inc_renzoku[name]
							if game_player.ag > 0 && (renzoku[name].floor % 100) != player[:extra_action_gauge] && player[:extra_action_gauge] != 100
								puts "#{version}/#{fname} #{game_player.name}"
								puts "actual=#{player[:extra_action_gauge]} expected=#{renzoku[name]}"
								# exit
							end
						else
							renzoku[name] = 0
						end
					end
					inc_renzoku = {}
				elsif event[:type] == 'battle_action' && ['Normal', 'Special'].include?(event[:subtype])
					if current_name
						player = sim.players[current_name]
						player.ag = 0 if player.buffs['凍結'] > 0 || player.buffs['麻痺'] > 0 || player.buffs['石化'] > 0
						ag = player.ag
						ag *= 0.8 + player.zone.position * 0.2 # 隊列補正
						ag *= player.stat_buffs['AG'] ? (1 + player.stat_buffs['AG'][:amount] * 0.01) : 1
						inc_renzoku[current_name] = (ag * 0.1) ** 0.8 * 1.8
						# puts "A name=#{current_name} AG=#{player.ag} 隊列=#{player.zone.position} 補正=#{player.stat_buffs['AG'] ? player.stat_buffs['AG'][:amount] : 0}"
					end
					current_name = event[:declarer]
				end
				sim.apply_event(event)
         end
      end
   end
end

result.each do |key, x|
   puts "#{key}: #{x.to_s}" if x.size > 11
end
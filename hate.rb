require 'json'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	dir_names: ["result02", "result02s00", "result02s01", "result03", "result03s00", "result04", "result04s00"],
	matcher: /(r\d+b\d)\.json/,
	# matcher: /(r916b4)\.json/,
}

root_dirs = search_config[:dir_names].map{|dir_name| "#{search_config[:root_dir]}/#{dir_name}/parsed/battle_actions" }

result = {}
result2 = Hash.new(0)

root_dirs.each do |root_dir|
   for fname in Dir.foreach(root_dir) do
      next unless search_config[:matcher].match(fname)

      File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
         game = JSON.load(file, nil, symbolize_names: true, create_additions: false)

         # 名前が同じプレイヤーがいるものは除外
         next if game[:players].size != game[:players].map{|p| p[:name]}.uniq.size

         players = {}
         teams = {}
         game[:players].each do |player|
            players[player[:name]] = player
         end

         sim = Simulator.new

         game[:beginning_phase][:players].each {|player| sim.apply_player_join(player) }
         game[:beginning_phase][:equips]&.each {|equip| sim.apply_equip(equip) }
         game[:beginning_phase][:events]&.each {|event| sim.apply_event(event) }

         teams = {}

         game[:events].each do |event|
            if event[:type] == 'round_state'
               teams = {}
               event[:players].each do |_player|
                  player = players[_player[:name]]
                  team = player[:team]
                  teams[team] = [] unless teams[team]
                  teams[team].push(player)
               end

            elsif event[:type] == 'battle_action' && event[:skill_name] == '通常攻撃'
               declarer_name = event[:declarer]
               declarer = sim.players[declarer_name]
               next if game[:players].select{|p| p[:name] == declarer_name}.first[:is_npc] || game[:players].select{|p| p[:name] == declarer_name}.first[:aid]

               target_name = nil
               event[:effects]&.each do |effect|
                  case effect[:type]
                  when 'damage', 'evade'
                     if target_name
                        # puts "A #{root_dir}/#{fname}"
                        break
                     end
                     target_name = effect[:target]
                  when 'consume_cover'
                     if target_name
                        # puts "A #{root_dir}/#{fname}"
                        break
                     end
                     target_name = effect[:target]
                  end
               end
               target = sim.players[target_name]
               unless target
                  # puts "B #{root_dir}/#{fname}"
                  next
               end
               unless declarer
                  puts "C #{root_dir}/#{fname}"
                  next
               end

               candidate = []
               out_of_range = []
               range = declarer.range
               next if range == 0
               declarer_team = players[declarer_name][:team]
               target_team = players[target_name][:team]
               if declarer_team == target_team
                  # 暴走中 念のためスキップ
                  next
               end
               ng = false
               teams[target_team].each do |member_info|
                  member = sim.players[member_info[:name]]
                  unless member && member.hate.expected
                     ng = true
                     break
                  end
                  if declarer.range + 1 >= declarer.zone.position + member.zone.position
                     candidate.push(member.hate.expected)
                  else
                     out_of_range.push(member.hate.expected)
                  end
               end
               next if ng

               candidate2 = candidate
               candidate = out_of_range if candidate.empty?
               key = candidate.sort.map(&:to_s).join(',')
               result[key] = Hash.new(0) unless result[key]
               result[key][target.hate.expected] += 1
               if key == "120" && target.hate.expected != 120
                  puts "Z #{root_dir}/#{fname}"
                  puts "#{declarer_name} #{target_name}"
                  p declarer.range, target.hate.expected
                  p candidate2, out_of_range
               end
               if candidate.select{|c| c == 120 }.size == 1 && candidate.select{|c| c == 10000 }.size == 1
                  result2[target.hate.expected] += 1
               end
            end
            sim.apply_event(event)
         end
      end
   end
end

result.each do |key, x|
   puts "#{key}: #{x.to_s}"
end

p result2
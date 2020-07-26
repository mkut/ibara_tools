require 'json'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	dir_names: ["result09"],
	matcher: /(r\d+b\d)\.json/,
	# matcher: /(r1508b3)\.json/,
}

root_dirs = search_config[:dir_names].map{|dir_name| "#{search_config[:root_dir]}/#{dir_name}/parsed/battle_actions" }

result = {}

root_dirs.each do |root_dir|
   for fname in Dir.foreach(root_dir) do
      next unless search_config[:matcher].match(fname)

      File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
         game = JSON.load(file, nil, symbolize_names: true, create_additions: false)

         # 名前が同じプレイヤーがいるものは除外
         next if game[:players].size != game[:players].map{|p| p[:name]}.uniq.size

         # p root_dir, fname

         players = {}
         game[:players].each do |player|
            players[player[:name]] = player
         end

         sim = Simulator.new

         game[:beginning_phase][:players].each {|player| sim.apply_player_join(player) }
         game[:beginning_phase][:equips]&.each {|equip| sim.apply_equip(equip) }
         game[:beginning_phase][:events]&.each {|event| sim.apply_event(event) }

         teams = {}

         game[:events].each do |event|
            if event[:type] == 'battle_action' && event[:skill_name] == '通常攻撃'
               sim.apply_event_only_buff(event)
               declarer_name = event[:declarer]
               declarer = sim.players[declarer_name]

               event[:effects]&.each do |effect|
                  case effect[:type]
                  when 'damage'
                     target_name = effect[:target]
                     target = sim.players[target_name]
                     next unless declarer && target
                     next if declarer.is_npc || target.is_npc
                     critical = effect[:critical_count]
                     blind = declarer.buffs['盲目']
                     
                     key = params.join(' ')
                     # next unless at.expected == 192 && df.expected == 115
                     result[key] = Hash.new(0) unless result[key]
                     result[key][critical] += 1
                     if key == "射程1 DX115 LK100 AG115 LK??(献身)"
                        STDERR.puts "A #{evaded} #{root_dir}/#{fname} #{declarer.name} #{target.name}"
                     end
                  end
               end
            end
            sim.apply_event(event)
         end
      end
   end
end

result = result.sort_by do |key, x|
   -x.values.sum
end

result.each do |key, x|
   evaded = x[-1]
   total = x.values.sum
   hit = total - evaded
   puts "#{key}: #{hit}/#{total} #{100.0*hit/total}%"
end
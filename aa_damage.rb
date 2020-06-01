require 'json'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
   dir_names: [
      "result02s00", "result02s01", "result02",
      "result03s00", "result03",
      "result04s00", "result04",
      "result05s00", "result05",
      # "result06s00", "result06s01", "result06",
      # "result07s00", "result07",
      # "result08",
   ],
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
                     next if players[declarer_name][:team] == players[target_name][:team]
                     at = declarer.at
                     at_buff = declarer.stat_buffs['AT'] ? declarer.stat_buffs['AT'][:amount] : 0
                     df = target.df
                     df_buff = target.stat_buffs['DF'] ? target.stat_buffs['DF'][:amount] : 0
                     next unless at.expected && df.expected
                     out_of_range = sim.out_of_range(declarer, target)
                     range = declarer.range
                     damage = effect[:amount]
                     critical = effect[:critical_count] || 0
                     adjust_dealt = declarer.damage_adjusts['与ダメージ'] ? declarer.damage_adjusts['与ダメージ'][:amount] : 0
                     adjust_taken = target.damage_adjusts['被ダメージ'] ? target.damage_adjusts['被ダメージ'][:amount] : 0
                     declarer_zone_effect = ['火特性', '水特性', '風特性', '地特性', '光特性', '闇特性', '与ダメージ'].select{|param| declarer.zone.effect&.effects&.include?(param) }
                     target_zone_effect = ['被ダメージ'].select{|param| target.zone.effect&.effects&.include?(param) }
                     affinities = ['火', '水', '風', '地', '光', '闇'].map{|e| declarer.affinities[e] }.select{|a| !a.events.empty? }
                     resistances = ['火', '水', '風', '地', '光', '闇'].map{|e| target.resistances[e] }.select{|a| !a.events.empty? }
                     params = [
                        "射程#{range}",
                        out_of_range > 0 ? "射程外#{out_of_range}" : nil,
                        # "AT#{at.expected}#{at_buff > 0 ? "+#{at_buff}%" : at_buff < 0 ? "#{at_buff}%" : ''}",
                        "#{at}#{at_buff > 0 ? "+#{at_buff}%" : at_buff < 0 ? "#{at_buff}%" : ''}",
                        # "DF#{df.expected}#{df_buff > 0 ? "+#{df_buff}%" : df_buff < 0 ? "#{df_buff}%" : ''}",
                        "#{df}#{df_buff > 0 ? "+#{df_buff}%" : df_buff < 0 ? "#{df_buff}%" : ''}",
                        affinities.map(&:to_s),
                        resistances.map(&:to_s),
                        declarer.buffs['麻痺'] > 0 ? '麻痺' : nil,
                        declarer.buffs['凍結'] > 0 ? '凍結' : nil,
                        target.buffs['衰弱'] > 0 ? '衰弱?' : nil,
                        target.buffs['石化'] > 0 ? '石化?' : nil,
                        adjust_dealt != 0 ? "与ダメージ#{adjust_dealt > 0 ? '+' : ''}#{adjust_dealt}%" : nil,
                        adjust_taken != 0 ? "被ダメージ#{adjust_taken > 0 ? '+' : ''}#{adjust_taken}%" : nil,
                        declarer_zone_effect.map{|effect| "#{effect}(#{declarer.zone.effect.name})"},
                        target_zone_effect.map{|effect| "#{effect}(#{target.zone.effect.name})"},
                        critical > 0 ? "Crit#{critical}" : nil,
                     ].flatten.compact
                     key = params.join(' ')
                     # next unless at.expected == 192 && df.expected == 115
                     result[key] = Hash.new(0) unless result[key]
                     result[key][damage] += 1
                     if key == "射程1 AT136(武器10(+5)/猛攻) DF125(防具10)"
                        STDERR.puts "A #{damage} #{root_dir}/#{fname}"
                     end
                  end
               end
            end
            sim.apply_event(event)
         end
      end
   end
end

result.each do |key, x|
   r = ""
   x.keys.sort.each do |dmg|
      r += "#{dmg}=>#{x[dmg]}, "
   end
   puts "#{key}: #{r}" if x.size > 9
end
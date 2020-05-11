require 'json'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	dir_names: ["result02", "result02s00", "result02s01", "result03", "result03s00", "result04", "result04s00", "result05", "result06"],
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
                  when 'evade', 'damage'
                     evaded = effect[:type] == 'evade'
                     target_name = effect[:target]
                     target = sim.players[target_name]
                     next unless declarer && target
                     next if declarer.is_npc || target.is_npc
                     declarer_side = sim.players.values.select{|pl| pl.zone.side == declarer.zone.side }.size
                     target_side = sim.players.values.select{|pl| pl.zone.side == target.zone.side }.size
                     dx = declarer.dx
                     dx_buff = declarer.stat_buffs['DX'] ? declarer.stat_buffs['DX'][:amount] : 0
                     ag = target.ag
                     ag_buff = target.stat_buffs['AG'] ? target.stat_buffs['AG'][:amount] : 0
                     dlk = declarer.lk
                     dlk_buff = declarer.stat_buffs['LK'] ? declarer.stat_buffs['LK'][:amount] : 0
                     tlk =  target.lk
                     tlk_buff = target.stat_buffs['LK'] ? target.stat_buffs['LK'][:amount] : 0
                     # next unless at.expected && df.expected
                     out_of_range = sim.out_of_range(declarer, target)
                     range = declarer.range
                     evaded = effect[:type] == 'evade'
                     critical = evaded ? -1 : (effect[:critical_count] || 0)
                     # adjust_dealt = declarer.damage_adjusts['与ダメージ'] ? declarer.damage_adjusts['与ダメージ'][:amount] : 0
                     # adjust_taken = target.damage_adjusts['被ダメージ'] ? target.damage_adjusts['被ダメージ'][:amount] : 0
                     # declarer_zone_effect = ['火特性', '水特性', '風特性', '地特性', '光特性', '闇特性', '与ダメージ'].select{|param| declarer.zone.effect&.effects&.include?(param) }
                     # target_zone_effect = ['被ダメージ'].select{|param| target.zone.effect&.effects&.include?(param) }
                     # affinities = ['火', '水', '風', '地', '光', '闇'].map{|e| declarer.affinities[e] }.select{|a| !a.events.empty? }
                     # resistances = ['火', '水', '風', '地', '光', '闇'].map{|e| target.resistances[e] }.select{|a| !a.events.empty? }
                     params = [
                        "#{declarer_side}vs#{target_side}",
                        "射程#{range}",
                        out_of_range > 0 ? "射程外#{out_of_range}" : nil,
                        "#{dx.expected ? "DX#{dx.expected}" : dx}#{dx_buff > 0 ? "+#{dx_buff}%" : dx_buff < 0 ? "#{dx_buff}%" : ''}",
                        "#{dlk.expected  ? "LK#{dlk.expected}" : dlk}#{dlk_buff > 0 ? "+#{dlk_buff}%" : dlk_buff < 0 ? "#{dlk_buff}%" : ''}",
                        # "#{at}#{at_buff > 0 ? "+#{at_buff}%" : at_buff < 0 ? "#{at_buff}%" : ''}",
                        "#{ag.expected  ? "AG#{ag.expected}" : ag}#{ag_buff > 0 ? "+#{ag_buff}%" : ag_buff < 0 ? "#{ag_buff}%" : ''}",
                        "#{tlk.expected  ? "LK#{tlk.expected}" : tlk}#{tlk_buff > 0 ? "+#{tlk_buff}%" : tlk_buff < 0 ? "#{tlk_buff}%" : ''}",
                        # "DF#{df}#{df_buff > 0 ? "+#{df_buff}%" : df_buff < 0 ? "#{df_buff}%" : ''}",
                        # affinities.map(&:to_s),
                        # resistances.map(&:to_s),
                        # declarer.buffs['麻痺'] > 0 ? '麻痺' : nil,
                        # declarer.buffs['凍結'] > 0 ? '凍結' : nil,
                        # target.buffs['衰弱'] > 0 ? '衰弱?' : nil,
                        # target.buffs['石化'] > 0 ? '石化?' : nil,
                        # adjust_dealt != 0 ? "与ダメージ#{adjust_dealt > 0 ? '+' : ''}#{adjust_dealt}%" : nil,
                        # adjust_taken != 0 ? "被ダメージ#{adjust_taken > 0 ? '+' : ''}#{adjust_taken}%" : nil,
                        # declarer_zone_effect.map{|effect| "#{effect}(#{declarer.zone.effect.name})"},
                        # target_zone_effect.map{|effect| "#{effect}(#{target.zone.effect.name})"},
                        # critical > 0 ? "Crit#{critical}" : nil,
                     ].flatten.compact
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
require 'json'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	dir_names: ["result02", "result02s00", "result02s01", "result03", "result03s00"],
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
            if event[:type] == 'battle_action'
               sim.apply_event_only_buff(event)
               declarer_name = event[:declarer]
               declarer = sim.players[declarer_name]

               prev_damage = nil
               event[:effects]&.each do |effect|
                  case effect[:type]
                  when 'damage'
                     prev_damage = effect
                  when 'heal'
                     next unless effect[:stat] == 'HP'
                     target_name = effect[:target]
                     target = sim.players[target_name]
                     next unless declarer.hl.expected && target.df.expected

                     base_heal_power = 0
                     case event[:skill_name]
                     when 'アイシング'
                        base_heal_power = (target.mhp ** 0.8 * 0.75).ceil
                     when 'ファーマシー'
                        base_heal_power = (target.mhp ** 0.8 * 0.6).ceil
                     when 'ヒール', 'アクアリカバー', 'ヒールハーブ', 'クイックレメディ', 'ホーリーポーション'
                        base_heal_power = (target.mhp ** 0.8 * 0.5).ceil
                     when 'ヒールポーション', 'アクアヒール'
                        base_heal_power = (target.mhp ** 0.8 * 0.45).ceil
                     when 'インフェクシャスキュア', 'アクアシェル'
                        base_heal_power = (target.mhp ** 0.8 * 0.4).ceil
                     when 'マナポーション'
                        base_heal_power = (target.mhp ** 0.8 * 0.25).ceil
                     when 'リリーフ'
                        base_heal_power = (target.mhp ** 0.8 * 0.15).ceil
                     when 'ドレイン'
                        base_heal_power = prev_damage[:amount]
                     else
                        next
                     end

                     hl = declarer.hl
                     hl_buff = declarer.stat_buffs['HL'] ? declarer.stat_buffs['HL'][:amount] : 0
                     df = target.df
                     df_buff = target.stat_buffs['DF'] ? target.stat_buffs['DF'][:amount] : 0
                     heal = effect[:amount]
                     params = [
                        "#{base_heal_power}(#{event[:skill_name]})",
                        "HL#{hl.expected}#{hl_buff > 0 ? "+#{hl_buff}%" : hl_buff < 0 ? "#{hl_buff}%" : ''}",
                        "#{df}#{df_buff > 0 ? "+#{df_buff}%" : df_buff < 0 ? "#{df_buff}%" : ''}",
                        target.buffs['腐食'] > 0 ? '腐食' : nil,
                     ].flatten.compact
                     key = params.join(' ')

                     result[key] = Hash.new(0) unless result[key]
                     result[key][heal] += 1

                     next if target.buffs['腐食'] > 0
                     puts "#{hl.expected*(1+0.01*hl_buff)}\t#{df.expected*(1+0.01*df_buff)}\t#{base_heal_power}\t#{heal}"
                  end
               end
            end
            sim.apply_event(event)
         end
      end
   end
end

result.each do |key, x|
   # puts "#{key}: #{x.to_s}"
end
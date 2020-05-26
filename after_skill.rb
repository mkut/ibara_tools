require 'json'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	versions: [
      "result03s00", "result03",
      "result04s00", "result04",
      "result05s00", "result05",
      "result06s00", "result06s01", "result06",
      "result07s00", "result07",
      "result08",
   ],
	matcher: /(r\d+b\d)\.json/,
	# matcher: /(r2b1)\.json/,
}

def flatten_effect2(effect, source)
	ret = [{effect: effect, source: source}]
	effect[:triggers]&.each do |trigger|
		ret += flatten_effect(trigger)
	end
	ret
end

def flatten_effect(ba)
	ret = []
	ba[:effects]&.each do |effect|
		ret += flatten_effect2(effect, ba)
	end
	ba[:triggers]&.each do |trigger|
		ret += flatten_effect(trigger)
	end
	return ret
end

result = { total_damage: 0, hit: 0, total_effect: 0, total_trigger: 0, total_skill_use: 0 }
result2 = {}
result3 = { total_trigger: 0, total_skill_use: 0 }
search_config[:versions].each do |version|
   /result(\d+(s\d+)?)/.match(version)
   v = $1
   root_dir = "#{search_config[:root_dir]}/#{version}/parsed/battle_actions"
   for fname in Dir.foreach(root_dir) do
      next unless search_config[:matcher].match(fname)

      File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
         game = JSON.load(file, nil, symbolize_names: true, create_additions: false)

         # 名前が同じプレイヤーがいるものは除外
         next if game[:players].size != game[:players].map{|p| p[:name]}.uniq.size

         # p root_dir, fname

         # sim = Simulator.new

         # game[:beginning_phase][:players].each {|player| sim.apply_player_join(player) }
         # game[:beginning_phase][:equips]&.each {|equip| sim.apply_equip(equip) }
         # game[:beginning_phase][:events]&.each {|event| sim.apply_event(event) }

         local_result = {}
         state = {}

         game[:events].each do |event|
            if ['Normal', 'Special'].include?(event[:subtype]) && event[:skill_name] != '通常攻撃'
               declarer = event[:declarer]
               local_result[declarer] = { skill_use: 0, skill_use_after: Hash.new(0), trigger: Hash.new(0), trigger_after: Hash.new(0) } unless local_result[declarer]
               local_result[declarer][:skill_use] += 1
               local_result[declarer][:skill_use_after][state[declarer][:level]] += 1 if state[declarer]
               result3[:total_skill_use] += 1 if declarer.match(/^こぐま/)
               event[:triggers]&.each do |trigger|
                  if trigger[:skill_name].match(/強撃LV(\d+)/)
                     lv = $1.to_i
                     result3[:total_trigger] += 1 if declarer.match(/^こぐま/)
                     if state[declarer] && state[declarer][:level] == lv
                        local_result[declarer][:trigger_after][lv] += 1
                     else
                        local_result[declarer][:trigger][lv] += 1
                     end
                     trigger[:effects]&.each do |effect|
                        if effect[:type] == 'damage'
                           result[:total_damage] += effect[:amount]
                           result[:hit] += 1
                           result[:total_effect] += 1
                           # puts "#{lv},#{effect[:amount]}"
                        elsif effect[:type] == 'evade'
                           result[:total_effect] += 1
                        else
                           # puts effect[:type]
                        end
                     end
                  end
               end
            end

            flatten_effect(event).each do |e|
               effect = e[:effect]
               source = e[:source]
               if effect[:type] == 'inc_passive' && effect[:passive] == '強撃'
                  target = effect[:target]
                  level = effect[:level]
                  state[target] = { level: 0 } unless state[target]
                  state[target][:level] += level
               end
            end

            # sim.apply_event(event)
         end
         local_result.each do |p, lr|
            # lr[:trigger].each do |lv, trigger_count|
            #    result2[lv] = { total_skill_use: 0, total_trigger: 0 } unless result2[lv]
            #    result2[lv][:total_skill_use] += lr[:skill_use]
            #    result2[lv][:total_trigger] += trigger_count
            # end
            lr[:skill_use_after].each do |lv, skill_use|
               result2[lv] = { total_skill_use: 0, total_trigger: 0 } unless result2[lv]
               result2[lv][:total_skill_use] += skill_use
               result2[lv][:total_trigger] += lr[:trigger_after][lv]
            end
         end

      end
   end
end

# trigger_rate = 100.0 * result[:total_trigger] / result[:total_skill_use]
# hit_rate = 100 * result[:hit] / result[:total_effect]
# average_damage = 1.0 * result[:total_damage] / result[:hit]
# expected_damage = average_damage * hit_rate / 100 * trigger_rate / 100

# puts "発動率: #{result[:total_trigger]} / #{result[:total_skill_use]} #{sprintf("%.2f", trigger_rate)}%"
# puts "命中率: #{result[:hit]} / #{result[:total_effect]} #{sprintf("%.2f", hit_rate)}%"
# puts "平均ダメージ: #{sprintf("%.2f", average_damage)}"
# puts "ダメージ期待値: #{sprintf("%.2f", expected_damage)}"

# result2.each do |lv, r|
#    trigger_rate = 100.0 * r[:total_trigger] / r[:total_skill_use]
#    puts "Lv #{lv}"
#    puts "発動率: #{r[:total_trigger]} / #{r[:total_skill_use]} #{sprintf("%.2f", trigger_rate)}%"
# end

trigger_rate = 100.0 * result3[:total_trigger] / result3[:total_skill_use]
puts "発動率: #{result3[:total_trigger]} / #{result3[:total_skill_use]} #{sprintf("%.2f", trigger_rate)}%"
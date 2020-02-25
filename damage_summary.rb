# coding: utf-8

require 'json'
require 'set'

search_config = {
	root_dir: "../release",
	dir_name: "result03",
	matcher: /(r\d+b\d)\.json/,
	# matcher: /(r1013b\d)\.html/,
}

prev_root_dir = "#{search_config[:root_dir]}/result02/parsed/battle_actions"
root_dir = "#{search_config[:root_dir]}/#{search_config[:dir_name]}/parsed/battle_actions"

skill_results = {}

existing_skills = Set.new

for fname in Dir.foreach(prev_root_dir) do
	next unless search_config[:matcher].match(fname)

   File.open("#{prev_root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
      game = JSON.load(file, nil, symbolize_names: true, create_additions: false)
      game[:events].each do |event|
         if event[:type] == 'battle_action' && event[:subtype] != 'ZoneEffect'
            name = event[:skill_name]
            existing_skills.add(name)
         end
      end
	end
end

for fname in Dir.foreach(root_dir) do
	next unless search_config[:matcher].match(fname)

   File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
      game = JSON.load(file, nil, symbolize_names: true, create_additions: false)
      game[:events].each do |event|
         if event[:type] == 'battle_action' && event[:subtype] != 'ZoneEffect'
            name = event[:skill_name]
            # next if existing_skills.include?(name)
            next unless name == "ブレイク"
            player = event[:declarer]
            skill_results[name] = { sum: 0, activate_count: 0, hit_count: 0, evaded_count: 0 } unless skill_results[name]
            skill_results[name][:activate_count] += 1
            event[:effects]&.each do |effect|
=begin
               if effect[:type] == "damage" && game[:players].find{|x| x[:name] == player}[:team] != game[:players].find{|x| x[:name] == effect[:target]}[:team]
                  skill_results[name][:sum] += effect[:amount]
                  skill_results[name][:hit_count] += 1
                  is_dmg = true
               elsif effect[:type] == "sp_damage" && game[:players].find{|x| x[:name] == player}[:team] != game[:players].find{|x| x[:name] == effect[:target]}[:team]
                     skill_results[name][:sum] += effect[:amount] * 10
                     skill_results[name][:hit_count] += 1
               elsif effect[:type] == "mixed_damage" && game[:players].find{|x| x[:name] == player}[:team] != game[:players].find{|x| x[:name] == effect[:target]}[:team]
                        skill_results[name][:sum] += effect[:sp_damage] * 10 + effect[:hp_damage]
                        skill_results[name][:hit_count] += 1
               elsif effect[:type] == "evade" && game[:players].find{|x| x[:name] == player}[:team] != game[:players].find{|x| x[:name] == effect[:target]}[:team]
                  skill_results[name][:evaded_count] += 1
                  is_dmg = true
               end
=end
            end
         end
      end
	end
end

skill_results.each do |skill, result|
   activate_count = result[:activate_count]
   average_per_cast = 1.0 * result[:sum] / activate_count
   hit_count = result[:hit_count]
   all_count = result[:evaded_count] + result[:hit_count]
   average_per_strike = 1.0 * result[:sum] / all_count
   hit_rate = 100.0 * hit_count / all_count
   next if all_count == 0
   puts "#{skill} 発動回数: #{activate_count} 平均ダメージ/判定: #{sprintf("%.2f", average_per_strike)} 平均ダメージ/発動: #{sprintf("%.2f", average_per_cast)} 命中率: #{sprintf("%.2f", hit_rate)}% (#{hit_count}/#{all_count})"
end
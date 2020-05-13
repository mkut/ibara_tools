# coding: utf-8

require 'json'
require 'set'

search_config = {
	root_dir: "../release",
	dir_name: "result07s00",
	fname: "r999b3.json",
}

fpath = "#{search_config[:root_dir]}/#{search_config[:dir_name]}/parsed/battle_actions/#{search_config[:fname]}"

result = {} # player_name => skill_name => damage

def process_event(result, event)
   return if event[:type] != 'battle_action' || event[:subtype] == 'ZoneEffect'
   skill_name = event[:skill_name]
   declarer = event[:declarer]
   result[declarer] = {} unless result[declarer]
   result[declarer][skill_name] = { damage: 0, count: 0, heal: 0 } unless result[declarer][skill_name]
   result[declarer][skill_name][:count] += 1
   event[:effects]&.each do |effect|
      case effect[:type]
      when'damage'
         result[declarer][skill_name][:damage] += effect[:amount]
      when 'heal'
         result[declarer][skill_name][:heal] += effect[:amount] if effect[:stat] == 'HP'
      end
      effect[:triggers]&.each do |trigger|
         process_event(result, trigger)
      end
   end
   event[:triggers]&.each do |trigger|
      process_event(result, trigger)
   end
   event[:pre_triggers]&.each do |trigger|
      process_event(result, trigger)
   end
end

File.open(fpath, "r:utf-8:utf-8") do |file|
   game = JSON.load(file, nil, symbolize_names: true, create_additions: false)
   game[:events].each do |event|
      process_event(result, event)
   end
end

result.each do |player_name, x|
   puts player_name
   total_damage = x.values.map{|x|x[:damage]}.sum
   x.each do |skill_name, y|
      next if y[:damage] == 0
      share = 100.0 * y[:damage] / total_damage
      puts "- #{skill_name}(#{y[:count]}): #{y[:damage]} (#{share}%)"
   end
   total_heal = x.values.map{|x|x[:heal]}.sum
   x.each do |skill_name, y|
      next if y[:heal] == 0
      share = 100.0 * y[:heal] / total_heal
      puts "* #{skill_name}(#{y[:count]}): #{y[:heal]} (#{share}%)"
   end
end
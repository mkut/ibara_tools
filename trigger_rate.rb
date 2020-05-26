require 'json'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	versions: [
      "result03s00", "result03",
      "result04s00", "result04",
      "result05s00", "result05",
      "result06s00", "result06s01", "result06",
      "result07s00", "result07"
   ],
	matcher: /(r\d+b\d)\.json/,
	# matcher: /(r2b1)\.json/,
}

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
	ba[:pre_triggers]&.each do |trigger|
		ret += flatten_effect(trigger)
	end
	return ret
end

def flatten_event2(effect)
	ret = []
	effect[:triggers]&.each do |trigger|
		ret += flatten_event(trigger)
	end
	ret
end

def flatten_event(ba)
	ret = [ba]
	ba[:effects]&.each do |effect|
		ret += flatten_event2(effect)
	end
	ba[:triggers]&.each do |trigger|
		ret += flatten_event(trigger)
	end
	ba[:pre_triggers]&.each do |trigger|
		ret += flatten_event(trigger)
	end
	return ret
end

total = 0
trigger = 0

search_config[:versions].each do |version|
   /result(\d+(s\d+)?)/.match(version)
   v = $1
   root_dir = "#{search_config[:root_dir]}/#{version}/parsed/battle_actions"
   puts "... #{version}"
   for fname in Dir.foreach(root_dir) do
      next unless search_config[:matcher].match(fname)

      File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
         game = JSON.load(file, nil, symbolize_names: true, create_additions: false)

         # 名前が同じプレイヤーがいるものは除外
         next if game[:players].size != game[:players].map{|p| p[:name]}.uniq.size

         # p root_dir, fname

         sim = Simulator.new

         game[:beginning_phase][:players].each {|player| sim.apply_player_join(player) }
         game[:beginning_phase][:equips]&.each {|equip| sim.apply_equip(equip) }
         game[:beginning_phase][:events]&.each {|event| sim.apply_event(event) }

         local_result = {}

         game[:events].each do |event|
            if event[:declarer]
               sim.apply_event_only_buff(event)
               declarer = sim.players[event[:declarer]]
               next unless declarer
               flatten_effect(event).each do |effect|
                  if effect[:type] == 'damage' && (effect[:critical_count] || 0) > 0
                     next if declarer.buffs['混乱'] > 0
                     local_result[declarer] = { total: 0, trigger: 0 } unless local_result[declarer]
                     local_result[declarer][:total] += 1
                  end
               end
               flatten_event(event).each do |ev|
                  if ev[:skill_name] == '衝撃波'
                     local_result[declarer] = { total: 0, trigger: 0 } unless local_result[declarer]
                     local_result[declarer][:trigger] += 1
                  end
               end
            end
            sim.apply_event(event)
         end

         local_result.each do |pl, r|
            if r[:trigger] > 0
               total += r[:total]
               trigger += r[:trigger]
            end
         end
      end
   end
end

rate = 100.0 * trigger / total

puts "#{trigger}/#{total} (#{rate}%)"
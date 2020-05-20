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

dmg_sum = 0
cnt = 0

result = {}
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

         sim = Simulator.new

         game[:beginning_phase][:players].each {|player| sim.apply_player_join(player) }
         game[:beginning_phase][:equips]&.each {|equip| sim.apply_equip(equip) }
         game[:beginning_phase][:events]&.each {|event| sim.apply_event(event) }

         game[:events].each do |event|
            prev_dmg_e = {}
            flatten_effect(event).each do |e|
               effect = e[:effect]
               source = e[:source]
               if ['damage', 'sp_damage', 'mixed_damage'].include?(effect[:type])
                  prev_dmg_e = e
               elsif effect[:type] == 'spread_debuff'
                  attack = effect[:target] == prev_dmg_e[:effect][:target]
                  target = sim.players[effect[:target]]
                  declarer = sim.players[source[:declarer]]
                  if target && declarer && (target.range != 1 || declarer.range != 1)
                     p root_dir, fname
                     puts "#{declarer.name} - #{target.name}"
                     puts "#{declarer.range} - #{target.range}"
                  end
               end
            end
            sim.apply_event(event)
         end
      end
   end
end

ave = dmg_sum / (cnt * 0.5)
puts ave

# result.each do |skill_stack, x|
#    puts "#{skill_stack}: #{x}"
# end
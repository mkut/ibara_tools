require 'json'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	versions: [
      "result08",
   ],
	matcher: /(r\d+b3)\.json/,
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

result = Hash.new(0)

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

         game[:events].each do |event|
				if ['Normal', 'Special', 'Card'].include?(event[:subtype]) && event[:skill_name] != '通常攻撃'
					result[event[:skill_name]] += 1
            end

            # sim.apply_event(event)
         end
      end
   end
end

result.sort_by{|k, v| -v }.each do |x|
	skill_name = x[0]
	count = x[1]
	puts "#{skill_name}: #{count}"
end
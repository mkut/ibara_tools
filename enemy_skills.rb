require 'json'
require 'set'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	versions: ["result02", "result03"],
	matcher: /(r\d+b\d)\.json/,
	# matcher: /(r1369b1)\.json/,
}

result = {}

def flatten_effect_events(effect)
   [
      effect[:triggers]&.map{|x| flatten_events(x)},
   ].flatten.compact
end

def flatten_events(event)
   [
      event,
      event[:effects]&.map{|x| flatten_effect_events(x)},
      event[:triggers]&.map{|x| flatten_events(x)},
   ].flatten.compact
end

def all_events(game)
   [
      game[:beginning_phase][:events],
      game[:events].map{|x| flatten_events(x)},

   ].flatten.compact
end

search_config[:versions].each do |version|
	root_dir = "#{search_config[:root_dir]}/#{version}/parsed/battle_actions"
   for fname in Dir.foreach(root_dir) do
      next unless search_config[:matcher].match(fname)

      File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
         game = JSON.load(file, nil, symbolize_names: true, create_additions: false)

         # p version, fname

         enemies = Set.new
         game[:players].each do |player|
            enemies.add(player[:name]) if player[:is_npc]
         end
         all_events(game).flatten.compact.each do |event|
            if event[:type] == 'battle_action' && ['Normal', 'Special', 'Passive'].include?(event[:subtype])
               declarer = event[:declarer]
               if enemies.include?(declarer)
                  /([^A-Z]*)[A-Z]?/.match(declarer)
                  real_name = $1
                  skill_name = (event[:subtype] == 'Special' ? '必殺' : '') + event[:skill_name]
                  result[real_name] = Set.new unless result[real_name]
                  result[real_name].add(skill_name)
					end
				end
         end
      end
   end
end

result.each do |key, x|
   puts key
   x.each do |skill_name|
      puts "  #{skill_name}"
   end
end
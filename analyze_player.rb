require 'json'
require 'set'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	versions: ["result06", "result05", "result04"],
   matcher: /(r\d+b\d)\.json/,
   name: "那咲",
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
         next unless game[:players].any? do |player|
            player[:name] == search_config[:name]
         end

         puts "#{root_dir} #{fname}"
         result = Hash.new(0)

         all_events(game).flatten.compact.each do |event|
            if event[:type] == 'battle_action' && ['Normal', 'Special', 'Passive', 'Card'].include?(event[:subtype])
               declarer = event[:declarer]
               next unless declarer == search_config[:name]
               skill_name = event[:skill_name]
               skill_name = skill_name += "-必殺#{event[:action_count]}" if event[:subtype] == 'Special'
               skill_name = skill_name += "-カード" if event[:subtype] == 'Card'
               result[skill_name] += 1
				end
         end

         result.each do |key, cnt|
            puts "  #{key} #{cnt}"
         end
      end
   end
end
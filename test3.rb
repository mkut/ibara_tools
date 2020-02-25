require 'json'
require_relative 'lib/simulator'

search_config = {
	root_dir: "../release",
	versions: ["result04", "result04s00"],
	matcher: /(r\d+b\d)\.json/,
	# matcher: /(r2b1)\.json/,
}

result = { cast: 0, pursuit: 0 }
n = 0
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

         players = {}
         game[:players].each do |player|
            players[player[:name]] = player
         end
         teams = {}

         passive_count = Hash.new(0)

         game[:beginning_phase][:equips]&.each do |equip|
            passive_count[equip[:player]] += 1 if equip[:effect1] == '追撃10'
            passive_count[equip[:player]] += 1 if equip[:effect2] == '追撃10'
            passive_count[equip[:player]] += 1 if equip[:effect3] == '追撃10'
         end

         game[:events].each do |event|
            next unless event[:type] == 'battle_action'
            if ['Normal', 'Special'].include?(event[:subtype])
               result[:cast] += passive_count[event[:declarer]]
            end
            event[:effects]&.each do |effect|
               if effect[:type] == 'inc_passive' && effect[:passive] =='自滅'
                  passive_count[effect[:target]] = 1
               end
            end
            event[:pre_triggers]&.each do |trigger|
               if /自滅LV(\d+)/.match(trigger[:skill_name])
                  p $1
                  result[:pursuit] += 1
               end
            end
         end
      end
   end
end

cast = result[:cast]
pursuit = result[:pursuit]
pursuit_rate = 100.0 * pursuit / cast

puts "#{sprintf("%.2f", pursuit_rate)}% (#{pursuit}/#{cast})"
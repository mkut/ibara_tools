# coding: utf-8

require 'json'
require 'set'
require_relative './lib/style'

search_config = {
	root_dir: "../release",
	dir_names: ["result02", "result03"],
	matcher: /(r\d+b\d)\.json/,
	# matcher: /(r1017b1)\.json/,
}

root_dirs = search_config[:dir_names].map{|dir_name| "#{search_config[:root_dir]}/#{dir_name}/parsed/battle_actions" }

root_dirs.each do |root_dir|
   for fname in Dir.foreach(root_dir) do
      next unless search_config[:matcher].match(fname)

      File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
         game = JSON.load(file, nil, symbolize_names: true, create_additions: false)

         hash = {}
=begin
         game[:beginning_phase][:players]&.each do |player|
            name = player[:name]
            hash[name] = [Style.of(player[:style]).ag]
         end

         game[:beginning_phase][:equips]&.each do |equip|
            name = equip[:player]
            hash[name].push(equip[:power]) if equip[:type] == '装飾'
         end

         game[:beginning_phase][:events]&.each do |event|
            event[:effects]&.each do |effect|
               if ['inc_stat', 'dec_stat'].include?(effect[:type]) && effect[:stat] == 'AG'
                  hash[effect[:target]].push(effect[:skill_name])
               end
            end
         end
=end
         game[:events]&.each do |event|
            if event[:type] == 'round_state'
               event[:players]&.each do |player|
                  hash[player[:name]] = [] unless hash[player[:name]]
                  hash[player[:name]].push(player[:extra_action_gauge])
               end
            end
         end

         hash.each do |name, v|
            if v.join(' ').start_with?('0 12 25 37 50 62')
               puts "#{root_dir}/#{fname} #{name}"
            end
         end
      end
   end
end
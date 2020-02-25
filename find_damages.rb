# coding: utf-8

require 'json'
require 'set'

search_config = {
	root_dir: "../release",
	dir_name: "result01",
	matcher: /(r\d+b1)\.json/,
	# matcher: /(r1013b\d)\.html/,
}

root_dir = "#{search_config[:root_dir]}/#{search_config[:dir_name]}/parsed/battle_actions"

dmgs = Hash.new(0)

for fname in Dir.foreach(root_dir) do
	next unless search_config[:matcher].match(fname)

   File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
      game = JSON.load(file, nil, symbolize_names: true, create_additions: false)

      all_passives = ['攻勢', '守勢', '猛攻']
      option = {
         weapon: [Set.new([10])],
         passive: [Set.new(['攻勢', '猛攻'])],
         skill_name: ['ピンポイント'],
         critical: 0,
      }

      weapon = Set.new
      game[:beginning_phase][:equips]&.each do |eq|
         if eq[:type] == '武器'
            weapon.add(eq[:power])
         end
      end
      next unless option[:weapon].include?(weapon)

      passive = Set.new
      game[:beginning_phase][:events].each do |ev|
         if ev[:type] == 'battle_action' && ev[:declarer] != 'ナレハテ' && all_passives.include?(ev[:skill_name])
            passive.add(ev[:skill_name])
         end
      end
      next unless option[:passive].include?(passive)

      game[:events].each do |event|
         if event[:type] == 'battle_action' && option[:skill_name].include?(event[:skill_name])
            event[:effects].each do |effect|
               crit = effect[:critical_count] || 0
               if effect[:type] == 'damage' && effect[:target] == 'ナレハテ' && crit == option[:critical]
                  dmgs[effect[:amount]] += 1
               end
            end
         end
      end
	end
end

dmgs_arr = []
dmgs.each do |dmg, cnt|
   dmgs_arr.push(dmg: dmg, cnt: cnt)
end

dmgs_arr.sort_by!{|x| x[:dmg] }
dmgs_arr.each do |x|
   puts "#{x[:dmg]} #{x[:cnt]}"
end
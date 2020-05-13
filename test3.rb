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
	return ret
end

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

         decrease_eyes_count = Hash.new(0)
         increase_eyes_count = Hash.new(0)

         game[:events].each do |event|
            next unless event[:type] == 'battle_action'
            if event[:skill_name] == 'ディクリースアイズ'
               decrease_eyes_count[event[:declarer]] += 1
            end
            if event[:skill_name] == 'インクリースアイズ'
               increase_eyes_count[event[:declarer]] += 1
            end
            flatten_effect(event).each do |effect|
               if ['dice_roll_over', 'dice_roll_under'].include?(effect[:type])
                  dec = decrease_eyes_count[event[:declarer]]
                  inc = increase_eyes_count[event[:declarer]]
                  key = "#{dec}-#{inc}"
                  result[key] = Hash.new(0) unless result[key]
                  result[key][effect[:actual1]] += 1
                  result[key][effect[:actual2]] += 1
                  result[key][effect[:actual3]] += 1
               end
            end
         end
      end
   end
end

result.each do |skill_stack, x|
   puts "#{skill_stack}: #{x}"
end
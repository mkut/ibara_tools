# coding: utf-8

search_config = {
	:env_name => "release",
	:dir_name => "result02",

	:matchers => [/変化させました！/,/変化することが判明しました！/],

	# 0 => normal, 1 => is_battle
	:matcher =>  /r\d+.html/
}

root_dir = "../#{search_config[:env_name]}/#{search_config[:dir_name]}/result/k/now"

ingredient_matcher = /<SPAN CLASS=Y3>ItemNo\.\d+ ([^<]*)<\/SPAN>/
composite_matcher = /<SPAN CLASS=Y3>([^I][^<]*)<\/SPAN>/

recipes = Hash.new {|hash, key| hash[key] = Hash.new(0)}

known_strength = {
	"不思議な武器" => 1,
	"不思議な防具" => 1,
	"不思議な装飾" => 1,
	"駄物" => 1,
	"不思議な牙" => 2,
	"不思議な石" => 2,
	"不思議な食材" => 2,
	"何か柔らかい物体" => 1,
}

for fname in Dir.foreach(root_dir) do
	if search_config[:matcher].match(fname)
		File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
			rangesref = nil
			file.each_line do |line|
				if search_config[:matchers].any? {|m| m.match(line)}
					ingredients = line.scan(ingredient_matcher).map{|x| x[0]}.sort!
					composite = line.scan(composite_matcher)[0][0]
					recipes[composite][ingredients] += 1
				end
			end
		end
	end
end

recipes.each do |composite, v|
	puts "#{composite}:"
	v.each do |ingredients, cnt|
		strs = ingredients.map{|x| known_strength[x]}
		s = strs.all?{|x| !x.nil?} ? strs.sum : nil
		puts "  #{s ? "[#{s}]" : ""} #{cnt} #{ingredients.map{|x| "#{x}[#{known_strength[x]||""}]"}.join(' ')}"
	end
end
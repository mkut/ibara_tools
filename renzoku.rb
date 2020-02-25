# coding: utf-8

env_name = "release"
dirname = "result#{ARGV[0]}"
fname = "#{ARGV[1]}.html"

File.open("../#{env_name}/#{dirname}/result/k/now/#{fname}", "r:utf-8:utf-8") do |file|
	file.each_line do |line|
		m = /<IMG SRC="..\/..\/p\/rz[12]\.png" WIDTH=(\d+) CLASS=STB>/.match(line)
		if m
			printf('%2d ', m[1])
		end
		
		if /<TD WIDTH=20 ALIGN=CENTER CLASS=Z><B CLASS=Z1>火<\/B><BR><B CLASS=Z2>水<\/B><BR><B CLASS=Z3>風<\/B><BR><B CLASS=Z4>地<\/B><BR><B CLASS=Z5>光<\/B><BR><B CLASS=Z6>闇<\/B><BR><\/TD>/.match(line)
			puts ""
		end
	end
end

puts ""
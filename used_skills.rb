# coding: utf-8

dic = {}
for fname in Dir.foreach("result03s00/result/k/now") do
#	if /r\d+\.html/.match(fname)
	if /r\d+b[3-4]\.html/.match(fname)
		File.open("result03s00/result/k/now/#{fname}", "r:utf-8:utf-8") do |file|
			file.each_line do |line|
				m = /<B CLASS=BSS\d>(<B CLASS=Z\d>)?([^<>]*)！！(<\/B>)?<\/B> <B CLASS=SK\d>>>([^<>]*)<\/B>/.match(line)
				if m
					dic[m[4]] = 0 if not dic.has_key? m[4]
					dic[m[4]] += 1
					next
				end
				m2 = /<B CLASS=BSS\d>(<B CLASS=Z\d>)?([^<>]*)！！(<\/B>)?<\/B>/.match(line)
				if m2
					dic[m2[2]] = 0 if not dic.has_key? m2[2]
					dic[m2[2]] += 1
					next
				end
			end
		end
	end
end

sorted = dic.sort { |a, b| b[1] <=> a[1] }

sorted.each do | skill, cnt |
	puts "#{cnt} #{skill}"
end

# <SPAN CLASS=Y3>ヒールポーション</SPAN> を研究しました！（深度0⇒<SPAN CLASS=Y3>1</SPAN>）<BR>
# m = /\<SPAN CLASS\=Y3\>(.*)\<\/SPAN\> を研究しました！/.match(line)

# ティンダー を習得！

# <SPAN CLASS=B3>武器LV</SPAN> を <SPAN CLASS=B3>20</SPAN> UP！
# 

# <TR><TD ALIGN=RIGHT STYLE="line-height:4px;"><IMG SRC="../../p/rz0.png" WIDTH=178 CLASS=STB><IMG SRC="../../p/rz1.png" WIDTH=22 CLASS=STB></TD></TR>

#
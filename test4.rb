search_config = {
	root_dir: "../release",
	versions: [
      "result03s00", "result03",
      "result04s00", "result04",
      "result05s00", "result05",
      "result06s00", "result06s01", "result06",
      "result07s00", "result07",
      "result08",
      "result09s00", "result09",
      "result10",
      "result11",
   ],
	matcher: /(r\d+)\.html/,
	# matcher: /(r2b1)\.json/,
}

search_config[:versions].each do |version|
   /result(\d+(s\d+)?)/.match(version)
   v = $1
   root_dir = "#{search_config[:root_dir]}/#{version}/result/k/now"
   puts "... #{version}"
   for fname in Dir.foreach(root_dir) do
      next unless search_config[:matcher].match(fname)

      File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
			file.each_line do |line|
            if /博打付加！/.match(line)
               puts fname
               puts line
				end
			end
      end
   end
end
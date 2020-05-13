[
   '01',
   '02s00', '02s01', '02',
   '03s00', '03',
   '04s00', '04',
   '05s00', '05',
   '06s00', '06s01', '06',
   '07s00', '07',
].each do |dir|
   command = "ruby parse.rb #{dir} all yes"
   puts command
   system(command)
end
module Version

   def self.of(version_text)
      Mapping.fetch(version_text) {|key| key.to_i }
   end

   Mapping = {
      '2s00' => 2,
      '2s01' => 2.1,
      '2' => 2.2,
      '3s00' => 3,
      '3' => 3.1,
      '4s00' => 4,
      '4' => 4.1,
      '5s00' => 5,
      '5' => 5.1,
   }

   Latest = 6
end
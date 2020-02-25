hints = [
   { at: 81, min: 859.375, max: 859.406 },
   { at: 91, min: 887.254, max: 887.369 },
   { at: 92, min: 890.476, max: 890.625 },
   { at: 102, min: 917.525, max: 917.648 },
   { at: 115, min: 952.427, max: 952.476 },
   { at: 125, min: 978.571, max: 978.641 },
   { at: 126, min: 980.582, max: 980.613 },
   { at: 136, min: 1006.315, max: 1006.667 },
   { at: 149, min: 1039.603, max: 1039.796 },
   { at: 159, min: 1064.356, max: 1064.762 },
   { at: 160, min: 1067.368, max: 1067.620 },
   { at: 170, min: 1092.380, max: 1092.632 },
]

for p0 in 60..100 #/10000
   pp = p0 * 0.01

   a0 = (hints.first[:at]**pp)
   a1 = (hints.last[:at]**pp)

   k_mn = (hints.last[:min]-hints.first[:max])/(a1-a0)
   k_mx = (hints.last[:max]-hints.first[:min])/(a1-a0)

   k0_mn = (k_mn*100).floor
   k0_mx = (k_mx*100).ceil

   for k0 in k0_mn..k0_mx #/1000
      k = k0 * 0.01
      c_mn = -99999
      c_mx = 99999
      hints.each do |hint|
         d = (hint[:at]**pp)*k
         c_mn = [c_mn, (hint[:min] - d)].max
         c_mx = [c_mx, (hint[:max] - d)].min
      end
      if c_mn - 0.5 < c_mx + 0.5
         puts "p=#{pp} k=#{k} c=[#{c_mn}, #{c_mx}]"
      end
   end
end


# (at+a)^p*k+c
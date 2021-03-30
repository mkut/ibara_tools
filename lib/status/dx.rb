require_relative 'status'

module Status
   class DX < Status
      def initialize(base_name = nil, base = nil)
         super('DX', base_name, base)
      end

      def apply_effect(effect, event)
         expected = @expected
         super(effect, event)
         @expected = expected
         return unless @expected && @base
         case event[:skill_name]
         when '猛攻'
            @expected += (@base * 0.1).floor
         when '器用LV10'
            @expected += (@base * 0.11).floor
         else
            @expected = nil
         end
      end

      def apply_equip(equip)
         # power_to_status = {10 => 5, 15 => 6, 17 => 6, 20 => 7, 30 => 9, 35 => 10, 40 => 11, 55 => 13, 67 => 15, 75 => 16, 90 => 18, 100 => 19, 150 => 25, 180 => 28}
         inc = ((equip[:power] + 1) ** 0.6 * 1.25).floor
         @events.push({
            skill_name: "#{equip[:type]}#{equip[:power]}(+#{inc})"
         })
         return unless @expected && @base
         @expected += inc
      end
   end
end
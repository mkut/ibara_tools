require_relative 'status'

module Status
   class DF < Status
      def initialize(base_name = nil, base = nil)
         super('DF', base_name, base)
      end

      def apply_effect(effect, event)
         expected = @expected
         super(effect, event)
         @expected = expected
         return unless @expected && @base
         case event[:skill_name]
         when '攻勢'
            @expected -= (@base * 0.3).floor
         when '守勢'
            @expected += (@base * 0.3).floor
         when '堅守'
            @expected += (@base * 0.1).floor
         when '防御LV10'
            @expected += (@base * 0.11).floor
         else
            @expected = nil
         end
      end

      def apply_equip(equip)
         # TODO もっとマシな方法で
         @events.push({
            skill_name: "#{equip[:type]}#{equip[:power]}"
         })
         return unless @expected && @base
         power_to_status = {10 => 5, 15 => 6, 17 => 6, 20 => 7, 30 => 9, 35 => 10, 40 => 11, 55 => 13, 67 => 15, 75 => 16, 90 => 18, 100 => 19, 150 => 25, 180 => 28}
         if power_to_status[equip[:power]]
            @expected += power_to_status[equip[:power]] * 2
         else
            @expected = nil
         end
      end
   end
end
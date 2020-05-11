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
         # TODO もっとマシな方法で
         @events.push({
            skill_name: "#{equip[:type]}#{equip[:power]}"
         })
         return unless @expected && @base
         @expected += equip[:power] / 5 + 3
      end
   end
end
require_relative 'status'

module Status
   class AG < Status
      def initialize(base_name = nil, base = nil)
         super('AG', base_name, base)
      end

      def apply_effect(effect, event)
         super(effect, event)
         return unless @expected && @base
         case event[:skill_name]
         when '堅守'
            @expected += (@base * 0.1).floor
         when '敏捷LV10'
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
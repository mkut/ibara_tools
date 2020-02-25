require_relative 'status'

module Status
   class HL < Status
      def initialize(base_name = nil, base = nil)
         super('HL', base_name, base)
      end

      def apply_effect(effect, event)
         super(effect, event)
         return unless @expected && @base
         case event[:skill_name]
         when '献身'
            @expected += (@base * 0.2).floor
         when '薬師'
            @expected += (@base * 0.15).ceil - 1
         when '回復LV10'
            @expected += (@base * 0.11).floor
         else
            @expected = nil
         end
      end
   end
end
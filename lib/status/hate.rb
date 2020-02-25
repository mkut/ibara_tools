require_relative 'status'

module Status
   class Hate < Status
      def initialize(base_name = nil, base = nil)
         super('HATE', base_name, base)
      end

      def apply_effect(effect, event)
         super(effect, event)
         return unless @expected && @base
         case event[:skill_name]
         when '太陽'
            @expected += 20 # *3?
         when '隠者'
            @expected -= 10 # /3?
         when 'アトラクト'
            @expected = nil # *2?
         else
            @expected = nil
         end
      end
   end
end
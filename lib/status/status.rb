module Status
   class Status
      attr_accessor :name, :base_name
      attr_accessor :base, :expected
      attr_accessor :expectable
      attr_accessor :events

      def initialize(name, base_name = nil, base = nil)
         @name = name
         @base = base
         @base_name = base_name
         @expected = base
         @expectable = true
         @events = []
      end

      def apply_effect(effect, event)
         @events.push(event)
      end

      def to_s
         effects = ([base_name || 'Unknown'] + @events.map{|e| e[:skill_name] }).join('/')
         expected = @expected || '??'
         ret = "#{@name}#{expected}(#{effects})"
      end
   end
end
module Effect
   module Proc
      def self.of_and(p1, p2)
         proc {|effect| p1.call(effect) && p2.call(effect) }
      end

      def self.of_field(key, val)
         proc {|effect|
            case val
            when Regexp
               val.match(effect[key])
            when Array
               val.include?(effect[key])
            else
               val == effect[key]
            end
         }
      end

      def self.of_type(types)
         of_field(:type, types)
      end

      def self.of_status_change(status_name)
         of_and(of_type(['inc_stat', 'dec_stat', 'up_stat', 'down_stat']), of_field(:stat, status_name))
      end
   end
end
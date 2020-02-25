class Style
   attr_accessor :name
   attr_accessor :order
   attr_accessor :at, :df, :dx, :ag, :hl

   def initialize(name, order, params = {})
      @name = name
      @order = order
      @at = params.fetch(:at, 100)
      @df = params.fetch(:df, 100)
      @dx = params.fetch(:dx, 100)
      @ag = params.fetch(:ag, 100)
      @hl = params.fetch(:hl, 100)
   end

   def self.of(style_name)
      return Styles[style_name] if Styles.has_key?(style_name)
      return Style.new(style_name, nil, at: nil, df: nil, dx: nil, ag: nil, hl: nil)
   end

   Styles = {
      '瞬速' => Style.new('瞬速', 1, df: 50),
      '疾駆' => Style.new('疾駆', 2, ag: 130),
      '強襲' => Style.new('強襲', 3, at: 150),
      '特攻' => Style.new('特攻', 4, at: 130, dx: nil),
      '順応' => Style.new('順応', 5, at: 115, df: 115, dx: 115, hl: 115),
      '堅固' => Style.new('堅固', 6, df: 140, hl: 120),
      '援助' => Style.new('援助', 7, hl: 120),
      '虎視' => Style.new('虎視', 8, ag: 60),
      '日和' => Style.new('日和', 9, at: 60, ag: 60, hl: 70),
   }
end
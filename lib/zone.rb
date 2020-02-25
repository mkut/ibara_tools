class ZoneEffect
   attr_accessor :name
   attr_accessor :effects

   def initialize(name, effects = [])
      @name = name
      @effects = effects
   end

   def self.of(e1, e2)
      Mapping[e1+e2]
   end

   ZoneEffects = {
      '烈火' => ZoneEffect.new('烈火', ['火特性']),
      '灼熱' => ZoneEffect.new('灼熱', ['火特性']),
      '荒天' => ZoneEffect.new('荒天', ['水特性']),
      '氷結' => ZoneEffect.new('氷結', ['水特性']),
      '浄界' => ZoneEffect.new('浄界', ['風特性']),
      '黒風' => ZoneEffect.new('黒風', ['風特性']),
      '泥沼' => ZoneEffect.new('泥沼', ['地特性']),
      '樹海' => ZoneEffect.new('樹海', ['地特性']),
      '閃光' => ZoneEffect.new('閃光', ['光特性']),
      '帯電' => ZoneEffect.new('帯電', ['光特性']),
      '黒炎' => ZoneEffect.new('黒炎', ['闇特性']),
      '瘴気' => ZoneEffect.new('瘴気', ['闇特性']),
      '煙霧' => ZoneEffect.new('煙霧', ['命中率', '回避率']),
      '乱離' => ZoneEffect.new('乱離', ['与ダメージ', '被ダメージ']),
      '消散' => ZoneEffect.new('消散', []),
   }

   Mapping = {
      '火水' => ZoneEffects['煙霧'],
      '火風' => ZoneEffects['烈火'],
      '火地' => ZoneEffects['灼熱'],
      '火光' => ZoneEffects['閃光'],
      '火闇' => ZoneEffects['黒炎'],

      '水火' => ZoneEffects['煙霧'],
      '水風' => ZoneEffects['荒天'],
      '水地' => ZoneEffects['泥沼'],
      '水光' => ZoneEffects['帯電'],
      '水闇' => ZoneEffects['氷結'],

      '風火' => ZoneEffects['烈火'],
      '風水' => ZoneEffects['荒天'],
      '風地' => ZoneEffects['乱離'],
      '風光' => ZoneEffects['浄界'],
      '風闇' => ZoneEffects['黒風'],

      '地火' => ZoneEffects['灼熱'],
      '地水' => ZoneEffects['泥沼'],
      '地風' => ZoneEffects['乱離'],
      '地光' => ZoneEffects['樹海'],
      '地闇' => ZoneEffects['瘴気'],

      '光火' => ZoneEffects['閃光'],
      '光水' => ZoneEffects['帯電'],
      '光風' => ZoneEffects['浄界'],
      '光地' => ZoneEffects['樹海'],
      '光闇' => ZoneEffects['消散'],

      '闇火' => ZoneEffects['黒炎'],
      '闇水' => ZoneEffects['氷結'],
      '闇風' => ZoneEffects['黒風'],
      '闇地' => ZoneEffects['瘴気'],
      '闇光' => ZoneEffects['消散'],
   }
end

class Zone
   attr_accessor :side, :position
   attr_accessor :fire, :water, :wind, :earth, :light, :dark

   def initialize(side, position, elements)
      @side = side
      @position = position
      @fire = elements[:火] || 0
      @water = elements[:水] || 0
      @wind = elements[:風] || 0
      @earth = elements[:地] || 0
      @light = elements[:光] || 0
      @dark = elements[:闇] || 0
   end

   def effect
      values = [[@fire, '火'], [@water, '水'], [@wind, '風'], [@earth, '地'], [@light, '光'], [@dark, '闇']].sort_by {|x| x[0] }
      return nil unless values[4][0] > values[3][0] && values[4][0] + values[5][0] > 5
      ZoneEffect.of(values[5][1], values[4][1])
   end
end
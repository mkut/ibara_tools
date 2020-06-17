require_relative 'style'
require_relative 'zone'
require_relative 'version'
require_relative 'status/base'
require_relative 'effect/proc'

class Player
   attr_accessor :name
   attr_accessor :style
   attr_accessor :is_npc
   attr_reader :at, :df, :dx, :ag, :hl, :hate, :lk
   attr_accessor :affinities, :resistances
   attr_accessor :mhp, :hp, :msp, :sp
   attr_accessor :range, :equipped
   attr_accessor :zone
   attr_accessor :buffs, :stat_buffs, :damage_adjusts

   def initialize(name, style, zone, is_npc = false)
      @name = name
      @style = Style::of(style)
      @zone = zone
      @is_npc = is_npc
      @at = Status::AT.new(@style.name, @style.at)
      @df = Status::DF.new(@style.name, @style.df)
      @dx = Status::DX.new(@style.name, @style.dx)
      @ag = Status::AG.new(@style.name, @style.ag)
      @hl = Status::HL.new(@style.name, @style.hl)
      @lk = Status::Status.new('LK', @style.name, 100)
      @hate = Status::Hate.new(@style.name, 100)
      @affinities = Hash.new{|hash, key| hash[key] = Status::Status.new("#{key}特性", @style.name) }
      @resistances = Hash.new{|hash, key| hash[key] = Status::Status.new("#{key}耐性", @style.name) }
      @range = @style.name == 'Unknown' ? 0 : 1
      @buffs = Hash.new(0)
      @stat_buffs = {}
      @damage_adjusts = {}
   end

   def at=(val)
      @at = val if @at > 0
   end

   def df=(val)
      @df = val if @df > 0
   end

   def dx=(val)
      @dx = val if @dx > 0
   end

   def ag=(val)
      @ag = val if @ag > 0
   end

   def hl=(val)
      @hl = val if @hl > 0
   end

   def hate=(val)
      @hate = val if @hate > 0
   end
end

class Simulator
   attr_reader :players
   attr_reader :version

   def initialize(version = nil)
      @version = version == nil ? Version::Latest : Version.of(version)
      @players = {}
   end

   def out_of_range(declarer, target)
      [declarer.zone.position + target.zone.position - declarer.range - 1, 0].max
   end

   def apply_player_join(player)
      name = player[:name]
      tmp_zone = Zone.new(player[:team], 1, {})
      if player[:is_npc]
         /([^A-Z]+)[A-Z]/.match(name)
         real_name = $1
         @players[name] = Player.new(name, real_name, tmp_zone, true)
      else
         @players[name] = Player.new(name, player[:style], tmp_zone)
      end
   end

   def apply_equip(equip)
      player = @players[equip[:player]]
      raise "unknown player name: #{equip[:player]}" unless player
      case equip[:type]
      when '武器', '大砲'
         player.at.apply_equip(equip)
         player.range = equip[:range] unless player.equipped
         player.equipped = true
      when '防具', '法衣'
         return if equip[:type] != '防具' && @version < 4 # v4未満では法衣が反映されていない
         player.df.apply_equip(equip)
      when '装飾', '魔晶'
         return if equip[:type] != '装飾' && @version < 4 # v4未満では魔晶が反映されていない
         player.dx.apply_equip(equip)
         player.ag.apply_equip(equip)
      end
   end

   def apply_event_only_buff(event)
      if event[:type] == 'battle_action' && ['Normal', 'Special'].include?(event[:subtype])
         declarer = @players[event[:declarer]]
         declarer.buffs = Hash.new(0)
         declarer.stat_buffs = {}
         event[:buffs]&.each do |buff|
            case buff[:type]
            when 'buff'
               declarer.buffs[buff[:name]] = buff[:amount]
            when 'status_buff'
               declarer.stat_buffs[buff[:status]] = {
                  amount: buff[:amount],
                  duration: buff[:duration],
               }
            end
         end
      end
   end

   def apply_event(event)
      if event[:type] == 'round_state'
         @delayed_cleanups&.each do |cleanup|
            cleanup[:stat_buffs]&.each do |buff|
               cleanup[:target].stat_buffs.delete([buff[:stat]])
            end
         end
         # zone effect check
         if @prev_zone_effects
            expected = @zones.map{|zone| zone.effect&.name }.compact.sort
            actual = @prev_zone_effects.sort
            STDERR.puts "zone effect mismatched: actual=#{actual.join(',')} expected=#{expected.join(',')}" if actual != expected
            @prev_zone_effects = []
         end

         @zones = []
         event[:zone_values].zip(['Alpha', 'Alpha', 'Alpha', 'Bravo', 'Bravo', 'Bravo'], [3, 2, 1, 1, 2, 3]) do |arr|
            @zones.push(Zone.new(arr[1], arr[2], arr[0]))
         end
         new_players = {}
         event[:players]&.each do |player|
            zone = @zones.select{|zone| zone.position == player[:position] && zone.side == player[:team] }.first
            new_player = @players.fetch(player[:name]) {|key| Player.new(player[:name], 'エイド', zone, true) unless @players[player[:name]] }
            new_player.mhp = player[:mhp]
            new_player.zone = zone
            new_players[player[:name]] = new_player
         end
         @players = new_players
      elsif event[:type] == 'battle_action' && event[:subtype] == 'ZoneEffect'
         @prev_zone_effects = [] unless @prev_zone_effects
         @prev_zone_effects.push(event[:skill_name])
      elsif event[:type] == 'battle_action'
         apply_event_only_buff(event)
         declarer = @players[event[:declarer]]
         prev_target = nil
         flatten_effects_in_event(event).each do |effect|
            # next unless @players[effect[:target]]
            case effect
            when Effect::Proc.of_type('summon')
               @players[effect[:target]] = Player.new(effect[:target], 'エイド', declarer.zone, true) # TODO 正しい隊列が分からない
            when Effect::Proc.of_status_change('AT')
               target = @players[effect[:target]]
               target.at.apply_effect(effect, event)
            when Effect::Proc.of_status_change('DF')
               target = @players[effect[:target]]
               target.df.apply_effect(effect, event)
            when Effect::Proc.of_status_change('DX')
               target = @players[effect[:target]]
               target.dx.apply_effect(effect, event)
            when Effect::Proc.of_status_change('AG')
               target = @players[effect[:target]]
               target.ag.apply_effect(effect, event)
            when Effect::Proc.of_status_change('HL')
               target = @players[effect[:target]]
               target.hl.apply_effect(effect, event)
            when Effect::Proc.of_status_change('HATE')
               target = @players[effect[:target]]
               target.hate.apply_effect(effect, event)
            when Effect::Proc.of_status_change('LK')
               target = @players[effect[:target]]
               target.lk.apply_effect(effect, event)
            when Effect::Proc.of_status_change(/[火水風地光闇]特性/)
               target = @players[effect[:target]]
               /([火水風地光闇])特性/.match(effect[:stat])
               target.affinities[$1].apply_effect(effect, event)
            when Effect::Proc.of_status_change(/[火水風地光闇]耐性/)
               target = @players[effect[:target]]
               /([火水風地光闇])耐性/.match(effect[:stat])
               target.resistances[$1].apply_effect(effect, event)
            # 連続行動ゲージ
            when Effect::Proc.of_type(['inc_debuff', 'spread_debuff'])
               target = @players[effect[:target]]
               target.buffs[effect[:debuff]] += effect[:amount]
            when Effect::Proc.of_type('dec_debuff')
               target = @players[effect[:target]]
               target.buffs[effect[:debuff]] -= effect[:amount]
            when Effect::Proc.of_type('inc_buff')
               target = @players[effect[:target]]
               target.buffs[effect[:buff]] += effect[:amount]
            when Effect::Proc.of_type('dec_buff')
               target = @players[effect[:target]]
               target.buffs[effect[:buff]] -= effect[:amount]
            when Effect::Proc.of_type('consume_buff')
               prev_target.buffs[effect[:buff]] -= effect[:amount]
            when Effect::Proc.of_type('steal_buff')
               target = @players[effect[:target]]
               target.buffs[effect[:buff]] -= effect[:amount]
               declarer.buffs[effect[:buff]] += effect[:amount]
            when Effect::Proc.of_type(['buff_stat', 'extend_buff_stat', 'shorten_buff_stat'])
               target = @players[effect[:target]]
               target.stat_buffs[effect[:stat]] = { amount: effect[:amount], duration: effect[:duration] }
            when Effect::Proc.of_type(['debuff_stat', 'extend_debuff_stat', 'shorten_debuff_stat'])
               target = @players[effect[:target]]
               target.stat_buffs[effect[:stat]] = { amount: -effect[:amount], duration: effect[:duration] }
            when Effect::Proc.of_type(['consume_buff_stat', 'consume_debuff_stat'])
               target = @players[effect[:target]]
               target.stat_buffs.delete(effect[:stat])
            when Effect::Proc.of_type('damage_adjust_dealt')
               target = @players[effect[:target]]
               target.damage_adjusts['与ダメージ'] = {
                  amount: effect[:amount],
                  duration: 1,
               }
            when Effect::Proc.of_type('damage_adjust_taken')
               target = @players[effect[:target]]
               target.damage_adjusts['被ダメージ'] = {
                  amount: effect[:amount],
                  duration: 1,
               }
            when Effect::Proc.of_type('damage')
               target = @players[effect[:target]]
               declarer.damage_adjusts.delete('与ダメージ') if declarer
               target.damage_adjusts.delete('被ダメージ')
            when Effect::Proc.of_type('cleanup')
               target = @players[effect[:target]]
               target.buffs[effect[:buff]] += effect[:amount]
               effect[:debuffs]&.each do |debuff|
                  target.buffs[debuff] = 0
               end
               effect[:buffs]&.each do |buff|
                  target.buffs[buff] = 0
               end
               @delayed_cleanups.push({
                  target: target,
                  stat_buffs: effect[:stat_buffs],
               })
            end

            prev_target = @players[effect[:target]]
         end
      end
   end

   def flatten_effects(effect)
      ret = [effect]
      effect[:triggers]&.each {|trigger| ret += flatten_effects_in_event(trigger) }
      ret
   end

   def flatten_effects_in_event(event)
      ret = []
      event[:pre_triggers]&.each {|effect| ret += flatten_effects_in_event(effect) }
      event[:effects]&.each {|effect| ret += flatten_effects(effect) }
      event[:triggers]&.each {|trigger| ret += flatten_effects_in_event(trigger) }
      ret
   end
end
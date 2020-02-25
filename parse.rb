# coding: utf-8

require 'json'
require 'nokogiri'
require 'fileutils'

if ARGV.size < 1
	STDERR.puts "USAGE: ruby parse.rb [更新回] ([更新ファイル]) ([再計算])"
	STDERR.puts "   EX: ruby parse.rb 01"
	STDERR.puts "   EX: ruby parse.rb 01 all"
	STDERR.puts "   EX: ruby parse.rb 01 r1013b1"
	STDERR.puts "   EX: ruby parse.rb 02s00 all yes"
	exit
end

search_config = {
	root_dir: "../release",
	dir_name: "result#{ARGV[0]}",
	matcher: ARGV.size == 1 || ARGV[1] == 'all' ? /^(r\d+b\d)\.html/ : /^(#{ARGV[1]})\.html/,
	overwrite: ARGV.size > 2,
}

matchers = {
	turn: /<A NAME="TN(\d+)"/,
	action: /<A NAME="P(\d+)N(\d+)T(\d+)"/,
}

root_dir = "#{search_config[:root_dir]}/#{search_config[:dir_name]}/result/k/now"
output_root_dir = "#{search_config[:root_dir]}/#{search_config[:dir_name]}/parsed/battle_actions"

FileUtils.mkdir_p(output_root_dir)

class NodeProc
	def self.of(tag, classes = [], **attrs)
		proc { |node|
			classes = [classes] unless classes.is_a?(Array)
			next false unless node.name == tag
			attrs['class'] = classes
			next false if !attrs.all? do |key, val|
				val = [val] unless val.is_a?(Array)
				key = key.to_s unless key.is_a?(String)
				if val == []
					next false unless node.attribute(key).nil?
				else
					next false unless val.include?(node.attribute(key)&.value)
				end
				true
			end
			true
		}
	end
end

class Parser
	def initialize(fname, doc)
		@fname = fname
		@doc = doc
		@is_npc_battle = !!/r\d+b1\.html/.match(fname)
	end

	def try_match(pattern, text, desc)
		m = pattern.match(text)
		unless m
			raise "parse error for #{desc} in #{@fname}: #{text}"
		end
		m
	end

	def parse_damage_effect(raw_text)
		case raw_text
		when /(.+)のSPに (\d+) のダメージ！ HPに (\d+) のダメージ！/
			{ type: 'mixed_damage', target: $1, hp_damage: $2.to_i, sp_damage: $3.to_i }
		when /(.+)のSPに (\d+) のダメージ！/
			{ type: 'sp_damage', target: $1, amount: $2.to_i }
		when /(.+)に (\d+) のダメージ！/
			{ type: 'damage', target: $1, amount: $2.to_i }
		when /(.+)は攻撃を回避！/
			{ type: 'evade', target: $1 }
		when /(.+)はダメージから逃れた！/
			{ type: 'evade_zone_effect', target: $1 }
		when /(.+)への攻撃を(.+)が庇った！/
			{ type: 'consume_cover', target: $1, player: $2 }
		when /効果の対象が存在しない！/
			{ type: 'fizzle' }
		when /⇒/
			nil
		when /このターン、(.*)により/
			{ type: 'zone_effect', zone_effect: $1 }
		when /この列の全領域値が減少！/
			{ type: 'zone_effect', zone_effect: '消散' }
		when /領域効果発生により、領域値\[(.+)\] 領域値\[(.+)\] がリセット！/
			{ type: 'zone_value_reset', elements: [$1, $2] }
		when /(.+)が強化された！/
			{ type: 'enpower_aid', target: $1 }
		when /前ターンのクリティカル数：(\d+)！/
			{ type: 'critical_count', target: $1.to_i }
		when /（ (.+)の((炎上|凍結|束縛|猛毒|麻痺|衰弱|盲目|腐食|朦朧|混乱|魅了|石化|暴走)が解消！|(祝福|守護|反射)が消滅！|(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)[+-](\d+)%が消滅！)* ）/
			target = $1
			debuffs = raw_text.scan(/(炎上|凍結|束縛|猛毒|麻痺|衰弱|盲目|腐食|朦朧|混乱|魅了|石化|暴走)が解消！/).flatten
			buffs = raw_text.scan(/(祝福|守護|反射)が消滅！/).flatten
			stat_buffs = raw_text.scan(/(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)([+-]\d+)%が消滅！/).map{|x| { stat: x[0], amount: x[1].to_i } }
			{ type: 'cleanup', target: target, debuffs: debuffs, buffs: buffs, stat_buffs: stat_buffs }
		when /――殺気が纏わりつく/
			nil
		else
			error([], "unknown damage effect: #{raw_text}")
			{ type: 'unknown', text: raw_text }
		end
	end

	def sanitize_player_name(player_name, players)
		original_declarer = player_name
		while players.select{|player| player[:name] == player_name }.empty?
			if /(.+)の([^の]*)/.match(player_name)
				player_name = $1
			else
				error([], "unknown declarer: #{original_declarer}")
				break
			end
		end
		player_name
	end

	def parse_effect(raw_text)
		# raw_text = node.text.gsub(/\n/, '')
		raw_text.chomp!
		case raw_text
		when /(.+)の(HP|SP)が (\d+) 回復！/
			{ type: 'heal', target: $1, stat: $2, amount: $3.to_i }
		when /(.+)から(SP)を (\d+) 得た！/
			{ type: 'receive_stat', target: $1, stat: $2, amount: $3.to_i }
		when /(.+)から(SP)を得られなかった！/
			{ type: 'receive_stat', target: $1, stat: $2, amount: 0 }
		when /(.+)の(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE|連続行動ゲージ)が増加！/
			{ type: 'inc_stat', target: $1, stat: $2 }
		when /(.+)のMHPが (\d+) 増加！HPが (\d+) 上昇！/
			{ type: 'inc_max_stat', target: $1, stat: 'HP', amount_max: $2.to_i, amount_current: $3.to_i }
		when /(.+)のMSPが (\d+) 増加！SPが (\d+) 上昇！/
			{ type: 'inc_max_stat', target: $1, stat: 'SP', amount_max: $2.to_i, amount_current: $3.to_i }
		when /(.+)の(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE|連続行動ゲージ)が減少！/
			{ type: 'dec_stat', target: $1, stat: $2 }
		when /(.+)の(HP|SP)が (\d+) 減少！/
			{ type: 'dec_stat', target: $1, stat: $2, amount: $3.to_i}
		when /(.+)のMHPが (\d+) 減少！HPが (\d+) 低下！/
			{ type: 'dec_max_stat', target: $1, stat: 'HP', amount_max: $2.to_i, amount_current: $3.to_i }
		when /(.+)のMSPが (\d+) 減少！SPが (\d+) 低下！/
			{ type: 'dec_max_stat', target: $1, stat: 'SP', amount_max: $2.to_i, amount_current: $3.to_i }
		when /(.+)の(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)が上昇！/
			{ type: 'up_stat', target: $1, stat: $2 }
		when /(.+)の(消費SP)が (\d+) 上昇！/
			{ type: 'up_stat', target: $1, stat: $2, amount: $3.to_i }
		when /(.+)のMHPが (\d+) 上昇！HPが (\d+) 上昇！/
			{ type: 'up_max_stat', target: $1, stat: 'HP', amount_max: $2.to_i, amount_current: $3.to_i }
		when /(.+)のMSPが (\d+) 上昇！SPが (\d+) 上昇！/
			{ type: 'up_max_stat', target: $1, stat: 'SP', amount_max: $2.to_i, amount_current: $3.to_i }
		when /(.+)の(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)が低下！/
			{ type: 'down_stat', target: $1, stat: $2 }
		when /(.+)の(消費SP)が (\d+) 低下！/
			{ type: 'down_stat', target: $1, stat: $2, amount: $3.to_i }
		when /(.+)のMHPが (\d+) 低下！HPが (\d+) 低下！/
			{ type: 'down_max_stat', target: $1, stat: 'HP', amount_max: $2.to_i, amount_current: $3.to_i }
		when /(.+)のMSPが (\d+) 低下！SPが (\d+) 低下！/
			{ type: 'down_max_stat', target: $1, stat: 'SP', amount_max: $2.to_i, amount_current: $3.to_i }
		when /(.+)から(HP|SP)を (\d+) 奪取！/
			{ type: 'steal_stat', target: $1, stat: $2, amount: $3.to_i }
		when /(.+)からMHPを (\d+) 奪取！HPを (\d+) 奪取！/
			{ type: 'steal_max_stat', target: $1, stat: 'HP', amount_max: $2.to_i, amount_current: $3.to_i }
		when /(.+)からMSPを (\d+) 奪取！SPを (\d+) 奪取！/
			{ type: 'steal_max_stat', target: $1, stat: 'SP', amount_max: $2.to_i, amount_current: $3.to_i }
		when /(.+)に(HP|SP)を (\d+) 譲渡！/
			{ type: 'give_stat', target: $1, stat: $2, amount: $3.to_i }
		when /(.+)から(.*)へ、MHP (\d+)  MSP (\d+) が分け与えられた！/
			{ type: 'share_max_stat', target: $2, source: $1, amount_mhp: $3.to_i, amount_msp: $4.to_i }
		when /(\d+) ターンの間、(.+)は ?(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)(\d+)％強化！/
			{ type: 'buff_stat', target: $2, stat: $3, duration: $1.to_i, amount: $4.to_i }
		when /(\d+) ターンの間、(.+)は ?(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)(\d+)％弱化！/
			{ type: 'debuff_stat', target: $2, stat: $3, duration: $1.to_i, amount: $4.to_i }
		when /(.+)の(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)(\d+)％強化が残り (\d+) ターンに延長！/
			{ type: 'extend_buff_stat', target: $1, stat: $2, duration: $4.to_i, amount: $3.to_i }
		when /(.+)の(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)(\d+)％弱化が残り (\d+) ターンに延長！/
			{ type: 'extend_debuff_stat', target: $1, stat: $2, duration: $4.to_i, amount: $3.to_i }
		when /(.+)の(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)(\d+)％強化が残り (\d+) ターンに短縮！/
			{ type: 'shorten_buff_stat', target: $1, stat: $2, duration: $4.to_i, amount: $3.to_i }
		when /(.+)の(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)(\d+)％弱化が残り (\d+) ターンに短縮！/
			{ type: 'shorten_debuff_stat', target: $1, stat: $2, duration: $4.to_i, amount: $3.to_i }
		when /(.+)の(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)(\d+)％強化が消滅！/
			{ type: 'consume_buff_stat', target: $1, stat: $2, amount: $3.to_i }
		when /(.+)の(AT|DF|DX|AG|HL|LK|.+特性|.+耐性|HATE)(\d+)％弱化が消滅！/
			{ type: 'consume_debuff_stat', target: $1, stat: $2, amount: $3.to_i }
		when /(.+)に(炎上|凍結|束縛|猛毒|麻痺|衰弱|盲目|腐食|朦朧|混乱|魅了|石化|暴走)を(\d+)(強制)?追加！/
			{ type: 'inc_debuff', target: $1, debuff: $2, amount: $3.to_i, forced: $4 == '強制' }
		when /(.+)は(炎上|凍結|束縛|猛毒|麻痺|衰弱|盲目|腐食|朦朧|混乱|魅了|石化|暴走)に抵抗！/
			{ type: 'resist_debuff', target: $1, debuff: $2 }
		when /(.+)は(炎上|凍結|束縛|猛毒|麻痺|衰弱|盲目|腐食|朦朧|混乱|魅了|石化|暴走)を(\d+)防御！/
			{ type: 'block_debuff', target: $1, debuff: $2, amount: $3.to_i }
		when /(.+)の(炎上|凍結|束縛|猛毒|麻痺|衰弱|盲目|腐食|朦朧|混乱|魅了|石化|暴走)深度を(\d+)軽減！/
			{ type: 'dec_debuff', target: $1, debuff: $2, amount: $3.to_i }
		when /(.+)の(炎上|凍結|束縛|猛毒|麻痺|衰弱|盲目|腐食|朦朧|混乱|魅了|石化|暴走)深度が(\d+)減少！/
			{ type: 'dec_debuff', target: $1, debuff: $2, amount: $3.to_i }
		when /(.+)の炎が(.+)へと燃え移った！（深度(\d+)）/
			{ type: 'spread_debuff', target: $2, source: $1, debuff: '炎上', amount: $3.to_i }
		when /(.+)に(祝福|守護|反射)を(\d+)(強制)?追加！/
			{ type: 'inc_buff', target: $1, buff: $2, amount: $3.to_i, forced: $4 == '強制' }
		when /(.+)の(祝福|守護|反射)深度が(\d+)減少！/
			{ type: 'dec_buff', target: $1, buff: $2, amount: $3.to_i }
		when /(.+)の(祝福|守護|反射)を(\d+)奪取！/
			{ type: 'steal_buff', target: $1, buff: $2, amount: $3.to_i }
		when /(.+)に対する攻撃を (\d+) 回護衛！/
			{ type: 'cover', target: $1, amount: $2.to_i }
		when /(.+)の次に与える攻撃ダメージへの補正が ([+-]\d+) ?％ になった！/
			{ type: 'damage_adjust_dealt', target: $1, amount: $2.to_i }
		when /(.+)の次に受ける攻撃ダメージへの補正が ([+-]\d+) ?％ になった！/
			{ type: 'damage_adjust_taken', target: $1, amount: $2.to_i }
		when /(.+)は(炎上|凍結|束縛|猛毒|麻痺|衰弱|盲目|腐食|朦朧|混乱|魅了|石化|暴走)への防御効果を(\d+)得た！/
			{ type: 'immune_debuff', target: $1, debuff: $2, amount: $3.to_i }
		when /(.+)のいる列の領域値\[(.+)\]が (\d+) 増加！/
			{ type: 'inc_zone_value', target: $1, element: $2, amount: $3.to_i }
		when /(.+)のいる列の領域値\[(.+)\]が (\d+) 減少！/
			{ type: 'dec_zone_value', target: $1, element: $2, amount: $3.to_i }
		when /　･･･と思いきや、守護により攻撃が回避された！（守護(\d+)減）/
			{ type: 'consume_buff', buff: '守護', amount: $1.to_i }
		when /　･･･と思いきや、反射により攻撃が跳ね返された！（反射(\d+)減）/
			{ type: 'consume_buff', buff: '反射', amount: $1.to_i }
		when /(.+)に (.+)LV(\d+) を付加！/
			{ type: 'inc_passive', target: $1, passive: $2, level: $3.to_i }
		when /(.+)の (.+)LVが (\d+) 増加！/
			{ type: 'inc_passive', target: $1, passive: $2, level: $3.to_i }
		when /(.+)の (.+)LVが (\d+) 減少！/
			{ type: 'dec_passive', target: $1, passive: $2, level: $3.to_i }
		when /･･･失敗！(.*)LVは付加されない！/
			{ type: 'failed_grant_passive', passive: $1, is_succeeded: false }
		when /(.+)の(.+)が(.+)に変化！/
			{ type: 'convert_passive', target: $1, before: $2, after: $3 }
		when /(.+)の(.*)が消滅！/
			{ type: 'consume_passive', target: $1, passive: $2 }
		when /(.+)の隊列が(\d+)列目になった！/
			{ type: 'move_position', target: $1, position: $2.to_i }
		when /(.+)の (.+) の残り発動回数が (\d+) 増加！/
			{ type: 'inc_skill_charge', target: $1, skill_name: $2, amount: $3.to_i }
		when /(.+)の総行動数が (\d+) になった！/
			{ type: 'set_action_count', target: $1, amount: $3.to_i }
		when /（目標値(\d+)以上 ･･･ \d ?\d ?\d = (\d+) ：(成功|失敗)！）/
			{ type: 'dice_roll', goal: $1.to_i, actual: $2.to_i, is_succeeded: $3 == '成功' }
		when /(.+)は自身のスキル･付加効果内のダイス目が高めになった！/
			{ type: 'enhance_dice', target: $1 }
		when /(.+)は自身のスキル･付加効果内のダイス目が低めになった！/
			{ type: 'weaken_dice', target: $1 }
		when /(.+)を召喚！/
			{ type: 'summon', target: $1 }
		when /(.+)はこれ以上召喚できない！/
			{ type: 'summon_failed', target: $1 }
		when /(.+)にビーフを投げつけた！/
			{ type: 'summon_beef', target: $1 }
		when /(.+)にビーフを投げつけたがもう受け取ってくれない！/
			{ type: 'summon_beef_failed', target: $1 }
		when /(.+)が発動する「(.*)」効果が強化！/
			{ type: 'enhance_skill', target: $1, skill_type: $2 }
		when /(.+)が発動する「(.*)」効果が弱化！/
			{ type: 'weaken_skill', target: $1, skill_type: $2 }
		when /(.+)は他者から炎上を移される確率が低下！/
			{ type: 'protect_debuff', target: $1, tag: '炎上' }
		when /(.+)は凍結によるHP･SP減少量が低下！/
			{ type: 'protect_debuff', target: $1, tag: '凍結' }
		when /(\d+) ターンの間、(.+)の攻撃が(火|水|風|地|光|闇)属性化！/
			{ type: 'elemental_attack_buff', target: $2, duration: $1.to_i, element: $3 }
		when /(.+)は現在HP割合が低いほど攻撃ダメージが上がるようになった！/
			{ type: 'special_passive', target: $1, passive: '血気' }
		when /(.+)は現在HP割合が低いほど被攻撃ダメージが下がるようになった！/
			{ type: 'special_passive', target: $1, passive: '背水' }
		when /(.+)は現在HP割合が低いほど攻撃命中率が上がるようになった！/
			{ type: 'special_passive', target: $1, passive: '死線' }
		when /(.+)は現在HP割合が低いほど攻撃回避率が上がるようになった！/
			{ type: 'special_passive', target: $1, passive: '見切' }
		when /(.+)の水属性スキルのHP増効果に水特性が影響するようになった！/
			{ type: 'special_passive', target: $1, passive: '水特性回復' }
		when /(.+)の風属性スキルのHP増効果に風特性が影響するようになった！/
			{ type: 'special_passive', target: $1, passive: '風特性回復' }
		when /(.+)の光属性スキルのHP増効果に光特性が影響するようになった！/
			{ type: 'special_passive', target: $1, passive: '光特性回復' }
		when /(.+)は敵をエイド化しやすくなった！/
			{ type: 'special_passive', target: $1, passive: '魅惑' }
		when /(.+)の召喚するNPCが強化！/
			{ type: 'special_passive', target: $1, passive: '召喚強化' }
		when /(.+)には何の効果もなかった！/ # アゲンスト
			{ type: 'no_effect', target: $1, subtype: 1 }
		when /(.+)には効果がなかった！/ # 転移門
			{ type: 'no_effect', target: $1, subtype: 2 }
		else
			error([], "unknown effect: #{raw_text}")
			{ type: 'unknown', text: raw_text }
		end
	end

	def error(trace, message)
		ignore_error = true
		full_message = "[#{@fname}][#{trace.join('>')}] #{message}"
		if ignore_error
			STDERR.puts full_message
		else
			raise full_message
		end
	end

	def unexpected_node_type_error(trace, node_type)
		error(trace, "unexpected node type '#{node_type}'.")
	end

	def parse_error(trace, expected, actual)
		error(trace, "parse error: #{expected} is expected but #{actual} is found.")
	end

	def parse_children(trace, node)
		node.children.map{|x| [parse_node(trace, x)]}.flatten.compact
	end

	def parse_node(trace = [], node = @doc.search('.MXM').first)
		# puts "#{node.name}.#{node.attribute('class')&.value}"
		case node
		when NodeProc::of('div', 'MXM')
			# Root
			trace += ['root']
			ret = {
				players: [],
				events: [],
			}
			current_buffs = []
			current_buff_battle_effects = []
			current_pre_triggers = []
			current_player = nil
			current_action_count = nil
			current_is_extra_action = nil
			current_text = ""
			prev_action = nil
			parse_children(trace, node).each do |child|
				case child[:type]
				when :battle_effect
					current_buff_battle_effects.push(child[:effect])
				when :buff, :status_buff
					current_buffs.push(child)
				when :buff_battle_effect, :ooc, :resist_ooc # TODO まとめる
					current_buff_battle_effects.push(child)
				when :player_turn
					current_player = child[:player]
					current_is_extra_action = child[:is_extra_action]
				when :action_count
					current_action_count = child[:count]
				when :battle_action
					if current_player || child[:subtype] == 'Card'
						child[:declarer] = current_player unless current_player.nil?
						child[:declarer] = sanitize_player_name(child[:declarer], ret[:players]) if child[:declarer]
						child[:action_count] = current_action_count unless current_action_count.nil?
						child[:buffs] = current_buffs unless current_buffs.empty?
						child[:is_extra_action] = current_is_extra_action unless current_is_extra_action.nil?
						child[:buff_battle_effects] = current_buff_battle_effects unless current_buff_battle_effects.empty?
						child[:pre_triggers] = current_pre_triggers unless current_pre_triggers.empty?
						ret[:events].push(child)

						# Add aid to player list
						child[:effects] && child[:effects].select{|effect| effect[:type] == 'summon'}.each do |effect|
							player_info = {
								name: effect[:target],
								team: ret[:players].find{|x| x[:name] == (child[:declarer] || current_player)}[:team],
								aid: true,
							}
							ret[:players].push(player_info)
						end

						current_buffs = []
						current_buff_battle_effects = []
						current_player = nil
						current_action_count = nil
						current_is_extra_action = nil
						current_pre_triggers = []
						prev_action = child
					elsif child[:is_effect_trigger]
						if prev_action
							prev_action[:triggers] = [] unless prev_action[:triggers]
							prev_action[:triggers].push(child)
						else
							error(trace, "prev effect is not found: triggered_skill=#{child[:skill_name]}")
						end
					else
						current_pre_triggers.push(child)
					end
				when :text
					current_text += child[:text]
				when :br
					current_text.gsub!(/\n/, '')
					next if current_text.empty?
					effect = parse_damage_effect(current_text)
					current_text = ''
					next unless effect
					ret[:events].last[:cleanup_effects] = [] unless ret[:events].last[:cleanup_effects]
					ret[:events].last[:cleanup_effects].push(effect)
				when :beginning_phase
					ret[:beginning_phase] = child
					child[:players].each do |player|
						player = player.dup
						player[:aid] = player[:style] == nil # TODO やばい
						ret[:players].push(player)
					end
					child[:events]&.each do |event|
						event[:declarer] = sanitize_player_name(event[:declarer], ret[:players]) if event[:declarer]
					end
				when :end_phase
					ret[:end_phase] = child
				when :round_state
					unless current_pre_triggers.empty?
						current_pre_triggers.each{|trigger| ret[:events].push(trigger) }
						current_pre_triggers = []
					end
					ret[:events].push(child)
				else
					unexpected_node_type_error(trace, child[:type])
				end
			end
			return ret
		when NodeProc::of('dl', ['BA1', 'BA2', 'BB1', 'BB2'])
			# BattleAction
			#   skill_name :: String
			#   subtype :: 'Normal' | 'Card' | 'Passive' | 'Special' | 'ZoneEffect'
			#   is_effect_trigger: Bool
			#   is_cancelled :: Bool
			#   declarer? :: String
			#   canceller? :: String
			#   effects? :: [Effect]
			#   triggers? :: [BattleAction]
			trace += ['battle_action']
			ret = {
				type: :battle_action,
				is_effect_trigger: !!(/BB\d/.match(node.attribute('class').value)),
				is_cancelled: false,
				subtype: 'Normal',
			}
			current_critical_count = 0
			current_text = ""
			prev_effect = nil
			parse_children(trace, node).each do |child|
				case child[:type]
				when :skill_declare
					ret[:skill_name] = child[:skill_name]
				when :card_declare
					ret[:subtype] = 'Card'
					ret[:declarer] = child[:declarer]
				when :passive_declare
					if child[:skill_name] == '通常攻撃'
						ret[:skill_name] = child[:skill_name]
					else
						ret[:subtype] = 'Passive'
						ret[:declarer] = child[:declarer]
						ret[:skill_name] = child[:skill_name]
					end
				when :special_skill
					ret[:subtype] = 'Special'
				when :critical_hit
					current_critical_count = child[:count]
				when :text
					current_text += child[:text]
				when :br
					current_text.chomp!
					next if current_text.empty?
					effect = parse_damage_effect(current_text)
					current_text = ''
					next unless effect
					effect[:critical_count] = current_critical_count if current_critical_count > 0
					ret[:effects] = [] unless ret[:effects]
					ret[:effects].push(effect)
					current_text = ''
					prev_effect = effect
				when :battle_effect
					ret[:effects] = [] unless ret[:effects]
					ret[:effects].push(child[:effect])
					prev_effect = child[:effect]
				when :battle_action
					if child[:is_effect_trigger]
						if prev_effect
							prev_effect[:triggers] = [] unless prev_effect[:triggers]
							prev_effect[:triggers].push(child)
						else
							error(trace, "prev effect is not found: triggered_skill=#{child[:skill_name]}")
						end
					else
						ret[:triggers] = [] unless ret[:triggers]
						ret[:triggers].push(child)
					end
				when :skill_cancel
					ret[:is_cancelled] = true
				when :skill_cancel_effect
				when :zone_effect_declare
					ret[:subtype] = 'ZoneEffect'
					ret[:skill_name] = child[:zone_effect_name]
				else
					unexpected_node_type_error(trace, child[:type])
				end
			end
			return ret
		when NodeProc::of('div', 'R870')
			# RoundState
			# or
			# BeginningPhase
			# or
			# EndPhase
			trace += ['round_state']
			ret = {}
			current_text = ""
			current_player = nil
			current_player_info = {}
			parse_children(trace, node).each do |child|
				case child[:type]
				when :party_name
				when :character_image
				when :player_join
					ret[:type] = :beginning_phase
					ret[:players] = [] unless ret[:players]
					ret[:players].push({
						name: child[:player],
						style: child[:style],
						team: child[:team],
						is_npc: @is_npc_battle && child[:team] == 'Bravo'
					})
					current_player = child[:player]
				when :aid_join
					ret[:players].push({
						name: child[:player],
						style: nil, # TODO
						team: child[:team],
						is_npc: true,
					})
				when :text
					current_text += child[:text]
				when :br
					current_text.chomp!
					case current_text
					when /.*を装備！/
					when /⇒ (.*)／(武器|大砲)：強さ(\d+)／［効果1］(.*) ［効果2］(.*) ［効果3］(.*)【射程(\d+)】(／特殊アイテム)?/
						ret[:equips] = [] unless ret[:equips]
						ret[:equips].push({
							player: current_player,
							name: $1,
							type: $2,
							power: $3.to_i,
							effect1: $4,
							effect2: $5,
							effect3: $6,
							range: $7.to_i,
							is_special: !!$8,
						})
					when /⇒ (.*)／(防具|法衣|装飾|魔晶)：強さ(\d+)／［効果1］(.*) ［効果2］(.*) ［効果3］([^／]*)(／特殊アイテム)?/
						ret[:equips] = [] unless ret[:equips]
						ret[:equips].push({
							player: current_player,
							name: $1,
							type: $2,
							power: $3.to_i,
							effect1: $4,
							effect2: $5,
							effect3: $6,
							is_special: !!$7,
						})
						ret[:equips].last[:range] = $7.to_i if $7
					when /この１時間内の戦闘に限り (.*) が付加されている！/
						ret[:passives] = [] unless ret[:passives]
						ret[:passives].push({
							player: current_player,
							passives: $1.split(' '),
						})
					end
					current_text = ""
				when :battle_action
					ret[:events] = [] unless ret[:events]
					ret[:events].push(child)
				when :zone_values
					ret[:type] = :round_state
					ret[:zone_values] = [] unless ret[:zone_values]
					ret[:zone_values].push(child[:elements])
				when :player_name
					current_player_info[:name] = child[:name]
					current_player_info[:extra_action_gauge] = 0
				when :extra_action_gauge
					current_player_info[:extra_action_gauge] = child[:value]
				when :player_hp
					current_player_info[:mhp] = child[:mhp]
					current_player_info[:hp] = child[:hp]
				when :player_sp
					current_player_info[:msp] = child[:msp]
					current_player_info[:sp] = child[:sp]
					if (current_player_info[:position])
						ret[:players] = [] unless ret[:players]
						ret[:players].push(current_player_info)
						current_player_info = {}
					end
				when :position
					current_player_info[:position] = child[:position]
					current_player_info[:team] = child[:team]
					if (current_player_info[:name])
						ret[:players] = [] unless ret[:players]
						ret[:players].push(current_player_info)
						current_player_info = {}
					end
				when :draw_game
					ret[:type] = :end_phase
					ret[:winner] = :draw
				when :win_game
					ret[:type] = :end_phase
					ret[:winner] = child[:winner]
				when :gain_influence
					ret[:influence_gain] = child[:amount]
				else
					unexpected_node_type_error(trace, child[:type])
				end
			end
			error(trace, 'Neither RoundState nor BeginningPhase is found.') unless ret[:type]
			return ret
		when NodeProc::of('b', ['BAA1', 'BAA2'])
			# PlayerTurn
			#   player :: String
			#   is_extra_action :: Bool
			# or
			# PlayerJoin
			#   player :: String
			#   style :: String
			#   team :: 'Alpha' | 'Bravo'
			trace += ['player_turn']
			/BAA(\d)/.match(node.attribute('class').value)
			team = $1.to_i == 1 ? 'Alpha' : 'Bravo'
			case node.text
			when /▼(.*)の(連続)?行動！/
				return {
					type: :player_turn,
					player: $1,
					is_extra_action: $2 ? true : false
				}
			when /▼(.*)は行動順.*【(.*)】で参戦！.*/
				return {
					type: :player_join,
					player: $1,
					style: $2,
					team: team,
				}
			when /(.*)のエイド：(.*)が参戦！/
				return {
					type: :aid_join,
					owner: $1,
					player: $2,
					team: team,
				}
			else
				error(trace, "unexpected node text: #{node.text}")
				return nil
			end
		when NodeProc::of('b', ['BSS1', 'BSS2'])
			# SkillDeclare
			#   skill_name :: String
			# or
			# ZoneEffectDeclare
			#   zone_effect_name :: String
			trace += ['skill_declare']
			ret = {
				type: :skill_declare,
			}
			parse_children(trace, node).each do |child|
				case child[:type]
				when :text
					case child[:text]
					when /(.*)！！/
						ret[:skill_name] = $1
					when /領域効果 "(.+)" が発生！/
						return {
							type: :zone_effect_declare,
							zone_effect_name: $1,
						}
					end
				when :skill_rename
					ret[:skill_name] = child[:skill_name]
				else
					unexpected_node_type_error(trace, child[:type])
				end
			end
			return ret
		when NodeProc::of('span', 'B2')
			# ActionCount
			#   count :: Int
			trace += ['action_count']
			ret = {
				type: :action_count,
			}
			parse_children(trace, node).each do |child|
				case child[:type]
				when :text
					if /\((\d+)\)/.match(child[:text])
						ret[:count] = $1.to_i
					end
				else
					unexpected_node_type_error(trace, child[:type])
				end
			end
			if ret.has_key?(:count)
				return ret
			else
				STDERR.puts "unknown action count in node type '#{trace.join('>')}'."
				return nil
			end
		when NodeProc::of('b', ['HK1', 'HK2'])
			# PassiveDeclare
			#   skill_name :: String
			#   declarer? :: String
			trace += ['passive_declare']
			ret = {
				type: :passive_declare,
			}
			current_text = ""
			parse_children(trace, node).each do |child|
				case child[:type]
				when :text
					current_text += child[:text]
				when :skill_rename
					ret[:skill_name] = child[:skill_name]
				else
					unexpected_node_type_error(trace, child[:type])
				end
			end
			unless ret[:skill_name]
				case current_text
				when /(.*)の([^の]+の祝福|祝福の詩|滅亡の風|時の牢|安息の風|数多の怨)！/
					ret[:skill_name] = $2
					ret[:declarer] = $1
				when /(.*)の([^の]*)！/
					ret[:skill_name] = $2
					ret[:declarer] = $1
				when /領域効果：(.+)！/
					ret[:skill_name] = $1
				when /通常攻撃！/
					ret[:skill_name] = '通常攻撃'
				when /暴走した力が自らを傷つける！！/
					ret[:skill_name] = '暴走'
				else
					error(trace, "unknown passive declare text: #{current_text}")
				end
			end
			return ret
		when NodeProc::of('b', ['SK1', 'SK2'])
			# SkillRename
			#   skill_name :: String
			trace += ['skill_rename']
			ret = {
				type: :skill_rename,
			}
			parse_children(trace, node).each do |child|
				case child[:type]
				when :text
					/>>(.*)/.match(child[:text])
					ret[:skill_name] = $1
				else
					unexpected_node_type_error(trace, child[:type])
				end
			end
			return ret
		when NodeProc::of('b', 'Y7i')
			# CardDeclare
			#   declarer :: String
			# or
			# DrawGame
			trace += ['card_declare']
			ret = {
				type: :card_declare
			}
			case node.text
			when /(.*)のカード発動！/
				return {
					type: :card_declare,
					declarer: $1,
				}
			when /引き分けとなりました。/
				return {
					type: :draw_game,
				}
			end
		when NodeProc::of('b', ['O7i', 'R7i'])
			# WinGame
			#   winner: 'Alpha' | 'Bravo'
			case node.text
			when /.*の勝利！/
				return {
					type: :win_game,
					winner: node.attribute('class').value == 'O7i' ? 'Alpha' : 'Bravo',
				}
			end
		when NodeProc::of('b', 'Y5')
			# GainInfluence
			case node.text.chomp
			when /　影響力が (\d+) 増加！/
				return {
					type: :gain_influence,
					amount: $1.to_i,
				}
			end
		when NodeProc::of('b', ['BS1', 'BS2'])
			# BattleEffect
			return {
				type: :battle_effect,
				effect: parse_effect(node.text)
			}
		when NodeProc::of('i', 'Y4')
			# CriticalHit
			trace += ['critical_hit']
			cnt = 0
			ret = {
				type: :critical_hit
			}
			parse_children(trace, node).each do |child|
				case child[:type]
				when :text
					parse_error(trace, "/Critical Hit!!/", child[:text]) unless /Critical Hit!!/.match(child[:text])
					cnt += 1
				when :br
				else
					unexpected_node_type_error(trace, child[:type])
				end
			end
			if cnt > 0
				return ret.merge({ count: cnt })
			else
				return parse_children(trace, node)
			end
		when NodeProc::of('td', ['Z', 'ZK0', 'ZK1', 'ZK2', 'ZK3', 'ZK4', 'ZK5', 'ZK6'])
			# ZoneValues
			#   elements :: [Element]
			trace += ['zone_values']
			ret = {
				type: :zone_values,
				elements: {},
			}
			ok = false # 属性名表示列を飛ばすため
			parse_children(trace, node).each do |child|
				case child[:type]
				when :zone_value
					ret[:elements][child[:element]] = child[:value] if child[:value] > 0
					ok = true
				when :br
				when :text
				else
					unexpected_node_type_error(trace, child[:type])
				end
			end
			return ok ? ret : nil
		when NodeProc::of('b', ['ZZ1', 'ZZ2', 'ZZ3', 'ZZ4', 'ZZ5', 'ZZ6', 'Z1', 'Z2', 'Z3', 'Z4', 'Z5', 'Z6'])
			# ZoneValue
			#   element :: String
			#   value :: Int
			if /^\d+$/.match(node.text)
				elements = ['', '火', '水', '風', '地', '光', '闇']
				parse_error(trace, '/Z+(\d)/', node.attribute('class').value) unless /Z+(\d)/.match(node.attribute('class').value)
				return {
					type: :zone_value,
					element: elements[$1.to_i],
					value: node.text.to_i,
				}
			else
				return parse_children(trace, node)
			end
		when NodeProc::of('img', 'STB', src: ['../../p/rz1.png', '../../p/rz2.png'])
			# ExtraActionGauge
			return {
				type: :extra_action_gauge,
				value: node.attribute('width').value.to_i,
			}
		when NodeProc::of('td', ['O2', 'R2'])
			# PlayerName
			return {
				type: :player_name,
				name: node.text,
			}
		when NodeProc::of('td', 'B2')
			# PlayerHP
			parse_error(trace, '/(\d+) \/ (\d+)/', node.text) unless /(\d+) \/ (\d+)/.match(node.text)
			return {
				type: :player_hp,
				mhp: $2.to_i,
				hp: $1.to_i,
			}
		when NodeProc::of('td', 'P2')
			# PlayerSP
			parse_error(trace, '/(\d+) \/ (\d+)/', node.text) unless /(\d+) \/ (\d+)/.match(node.text)
			return {
				type: :player_sp,
				msp: $2.to_i,
				sp: $1.to_i,
			}
		when NodeProc::of('b', ['IJ1', 'IJ2', 'IJ3', 'IJ4', 'IJ5', 'IJ6', 'IJ7', 'IJ8', 'IJ9', 'IJ10', 'IJ11', 'IJ12', 'IJ13', 'IJ14', 'IJ15', 'IJ16'])
			# Buff
			# or
			# BuffBattleEffect
			case node.text
			when /(炎上|猛毒)により (\d+) のダメージ！/
				return { type: :buff_battle_effect, buff: $1, damage: $2.to_i }
			when /(腐食|石化)により (\d+) のダメージ！MHPが (\d+) 減少/
				return { type: :buff_battle_effect, buff: $1, damage: $2.to_i, mhp_damage: $3.to_i }
			when /(凍結)により (\d+) のダメージ！SPに (\d+) のダメージ/
				return { type: :buff_battle_effect, buff: $1, damage: $2.to_i, sp_damage: $3.to_i }
			when /(朦朧)によりSPに (\d+) のダメージ！/
				return { type: :buff_battle_effect, buff: $1, sp_damage: $2.to_i }
			when /要求SP不足により暴走！\(\+(\d+)\)/
				return { type: :ooc, reason: :short_sp, amount: $1.to_i }
			when /主人不在により暴走！\(\+(\d+)\)/
				return { type: :ooc, reason: :absent_owner, amount: $1.to_i }
			when /要求SP不足により暴走しかけたが堪えた！/
				return { type: :resist_ooc, reason: :short_sp }
			when /(朦朧)によりSPに  のダメージ！/
				return { type: :buff_battle_effect, buff: $1, sp_damage: 0 } # 02s00でのバグったログ
			else
				error(trace, "unknown buff text: #{node.text}")
			end
		when NodeProc::of('b', 'F5i')
			# zone effect
			return parse_children(trace, node)
		when NodeProc::of('b', 'B6i')
			# SkillCancel
			parse_error(trace, '/(.+)がスキルをキャンセル！/', node.text) unless /(.+)がスキルをキャンセル！/.match(node.text)
			return {
				type: :skill_cancel,
				canceller: $1,
			}
		when NodeProc::of('b', 'B4i')
			# SkillCancelEffect
			parse_error(trace, '/(.+)は(.+)を封じられた！/', node.text) unless /(.+)は(.+)を封じられた！/.match(node.text)
			return {
				type: :skill_cancel_effect,
				target: $1,
				skill_name: $2,
			}
		when NodeProc::of('b', 'Y6i')
			# SpecialSkill
			parse_error(trace, '/必殺スキル発動！/', node.text) unless /必殺スキル発動！/.match(node.text)
			return { type: :special_skill }
		when NodeProc::of('td', [], colspan: '3')
			# Position
			trace += ['position']
			align = node.attribute('align')&.value
			parse_children(trace, node).each do |child|
				case child[:type]
				when :character_image
					case node.parent.children.index(node)
					when 1
						return { type: :position, team: 'Alpha', position: align == 'RIGHT' ? 1 : align == 'CENTER' ? 2 : 3 }
					when 5
						return { type: :position, team: 'Bravo', position: align == 'RIGHT' ? 3 : align == 'CENTER' ? 2 : 1 }
					end
				when :text
				else
					unexpected_node_type_error(trace, child[:type])
				end
			end
			return parse_children(trace, node)
		when NodeProc::of('text')
			return nil if node.text.chomp.empty?
			return {
				type: :text,
				text: node.text,
			}
		when NodeProc::of('b', ['F7i', 'F8i'])
			# skill declare wrapper
			return parse_children(trace, node)
		when NodeProc::of('b', 'Y4i')
			# skill effect wrapper
			return parse_children(trace, node)
		when NodeProc::of('i', 'F6i')
			# announcement wrapper
			return parse_children(trace, node)
		when NodeProc::of('i', 'F5')
			# player turn wrapper
			return parse_children(trace, node)
		when NodeProc::of('i', 'Y3')
			# skill effect wrapper
			return parse_children(trace, node)
		when NodeProc::of('b', 'F2')
			# buff wrapper
			ret = []
			node.children.each do |child|
				case child.text
				when /\[(.+)([+-]\d+)%:(\d+)T\]/
					ret.push({
						type: :status_buff,
						status: $1,
						amount: $2.to_i,
						duration: $3.to_i,
					})
				when /\[(.撃化):(\d+)T\]/
					ret.push({
						type: :buff,
						name: $1,
						duration: $2.to_i,
					})
				when /\[(.+):(\d+)\]/
					ret.push({
						type: :buff,
						name: $1,
						amount: $2.to_i,
					})
				end
			end
			ret
		when NodeProc::of('span', 'Y3')
			# equipment wrapper
			return parse_children(trace, node)
		when NodeProc::of('b', 'Y4')
			# passive wrapper
			return parse_children(trace, node)
		when NodeProc::of('span', 'Y6')
			# influence wrapper
			return parse_children(trace, node)
		when NodeProc::of('span', 'Z6')
			# flavor wrapper
			return parse_children(trace, node)
		when NodeProc::of('b', ['L6', 'R6'])
			# party name
			return {
				type: :party_name,
				side: node.attribute('class').value == 'L6' ? 'Alpha' : 'Bravo',
				name: node.text,
			}
		when NodeProc::of('b', ['WD0', 'WD1'])
			# character name
			return nil
		when NodeProc::of('img', 'IC0')
			# character image
			return { type: :character_image }
		when NodeProc::of('div', ['SE1', 'SE2'])
			# character speech
			return nil
		when NodeProc::of('b', ['BA1', 'BA2'])
			# player knock out / announcement
			return nil
		when NodeProc::of('td', 'D6'), NodeProc::of('span', 'D6')
			# initiative check dice
			return nil
		when NodeProc::of('div', ['INIJN', 'INIYA'])
			# initiative
			return nil
		when NodeProc::of('img', ['TN0', 'TN1', 'TN2', 'TN3', 'TN4', 'TN5', 'TN6', 'TN7', 'TN8', 'TN9'])
			# turn number
			return nil
		when NodeProc::of('div', 'CL')
			# ???
			return nil
		when NodeProc::of('img', 'STB')
			# ???
			return nil
		when NodeProc::of('img', ['RHEAD', 'RFOOT', 'RNE']), NodeProc::of('img')
			return nil
		when NodeProc::of('br')
			return { type: :br }
		when NodeProc::of('dl'),
			NodeProc::of('div'),
			NodeProc::of('table'),
			NodeProc::of('tbody'),
			NodeProc::of('tr'),
			NodeProc::of('td'),
			NodeProc::of('a'),
			NodeProc::of('b'),
			NodeProc::of('span'),
			NodeProc::of('i'),
			NodeProc::of('font')
			return parse_children(trace, node)
		else
			error(trace, "unknown node #{node.name}.#{node.attribute('class')&.value}.")
			return nil
		end
	end
end

updated_file_count = 0
for fname in Dir.foreach(root_dir) do
	fname_m = search_config[:matcher].match(fname)
	next unless fname_m
	fname_out = "#{fname_m[1]}.json"
	next if !search_config[:overwrite] && File.exist?("#{output_root_dir}/#{fname_out}")

	# ファイル読み込み
	parser = nil
	File.open("#{root_dir}/#{fname}", "r:utf-8:utf-8") do |file|
		doc = Nokogiri::HTML.parse(file)
		parser = Parser.new(fname, doc)
	end

	# パース
	begin
		actions = parser.parse_node
	rescue => e
		STDERR.puts "error in #{fname}"
		raise e
	end

	# 書き出し
	File.open("#{output_root_dir}/#{fname_out}", "w") do |file|
		file.write(JSON.generate(actions))
		updated_file_count += 1
	end
end

puts "#{updated_file_count} files are updated."
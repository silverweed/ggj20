class_name EventParser

static func synerr(fname: String, lineno: int, msg: String):
	print("[syntax_error] at ", fname, ":", lineno, ": ", msg)
	

static func parse_all_events(fname: String, file: File): # -> [Dict(name -> Event), Dict(name -> Proxy_Event)]
	var events = {}
	var proxies = {}
	# Format:
	#   event event_name # comment is ignored
	#   title Event Title (more than 1 word allowed)
	#   ---
	#   event description (multiline allowed)
	#   ---
	#   change [expr] stat1 +N
	#   change []     stat2 -M # events are independent
	#   module []     name  +lv/-lv # name can start with m_, it'll be ignored.
	#   > Choice A
	#     [expr] outcome_1
	#     ...
	#     []     outcome_N
	#   > [expr] Choice B # choice % are independent
	#      ...
	#   end
	# ...repeats
	# There are also "proxies", which are used to select between 
	# events without interaction with user
	var cur_event: EventTypes.Event = null
	var cur_event_key = ""
	var started_desc = false
	var desc = ""
	var cur_choice: EventTypes.Event_Choice = null
	var lineno = 0
	var cur_proxy: EventTypes.Proxy_Event = null
	while !file.eof_reached():
		var line = file.get_line()
		lineno += 1
		
		if started_desc:
			if line.begins_with("---"):
				started_desc = false
				cur_event.description = desc
				desc = ""
			else:
				desc += line + "\n"
			continue
			
		var noncomment_comment = line.split("#", true, 2)
		line = noncomment_comment[0].strip_edges()
			
		if line.begins_with("event"):
			if cur_event != null or cur_proxy != null:
				synerr(fname, lineno, "previous event or proxy wasn't ended when read 'event'")
				break
			cur_event = EventTypes.Event.new()
			cur_event_key = line.trim_prefix("event").strip_edges()
		
		elif line.begins_with("proxy"):
			if cur_event != null or cur_proxy != null:
				synerr(fname, lineno, "previous event or proxy wasn't ended when read 'event'")
				break
			cur_proxy = EventTypes.Proxy_Event.new()
			cur_event_key = line.trim_prefix("proxy").strip_edges()
			cur_choice = EventTypes.Event_Choice.new()
			
		elif line.begins_with("title"):
			if cur_event == null:
				synerr(fname, lineno, "found 'title' not belonging to any event")
				break
			cur_event.title = line.trim_prefix("title").strip_edges()
			
		elif line.begins_with("---"):
			assert(!started_desc)
			if cur_event == null:
				synerr(fname, lineno, "found 'start description' not belonging to any event")
				break
			if cur_event.description.length() > 0:
				synerr(fname, lineno, "event description started more than once")
				break
			started_desc = true
			
		elif line.begins_with(">"):
			if cur_proxy != null:
				synerr(fname, lineno, "proxies cannot have explicit choices.")
				break
			if cur_choice != null:
				cur_event.choices.push_back(cur_choice)
			cur_choice = EventTypes.Event_Choice.new()
			line = line.trim_prefix(">").strip_edges()
			# check if condition is present
			if line[0] == "[":
				var splitted = line.substr(1).split("]")
				cur_choice.chance_expr = splitted[0].strip_edges()
				cur_choice.description = splitted[1].strip_edges()
			else:
				cur_choice.chance_expr = ""
				cur_choice.description = line
		
		elif line.begins_with("["):
			if cur_choice == null:
				synerr(fname, lineno, "found outcome line outside a choice/stat change")
				break
			line = line.trim_prefix("[")
			var tokens = line.split("]")
			if tokens.size() != 2:
				synerr(fname, lineno, "invalid line [" + line)
				break
				
			var outcome = EventTypes.Event_Outcome.new();
			outcome.chance_expr = tokens[0].trim_suffix("]").strip_edges()
			outcome.linked_event = tokens[1].strip_edges()
			cur_choice.outcomes.push_back(outcome)
		
		elif line.begins_with("change"):
			if cur_choice != null and cur_event != null:
				synerr(fname, lineno, "events cannot have stat change inside choice")
				break
			if cur_event == null and cur_proxy == null:
				synerr(fname, lineno, "found stat change outside an event or proxy")
				break
			line = line.trim_prefix("change").strip_edges().trim_prefix("[")
			var tokens = line.split("]")
			if tokens.size() != 2:
				synerr(fname, lineno, "invalid line [" + line)
				break
				
			var stat_change = EventTypes.Stat_Change.new();
			stat_change.chance_expr = tokens[0].trim_suffix("]").strip_edges()
			var change_part = tokens[1].strip_edges().split(" ")
			stat_change.stat_name = change_part[0]
			stat_change.change = int(change_part[1])
			if cur_event:
				cur_event.stat_changes.push_back(stat_change)
			else:
				assert(cur_proxy != null)
				cur_proxy.stat_changes.push_back(stat_change)
		
		elif line.begins_with("module"): 
			# Copypasted from change
			if cur_choice != null and cur_event != null:
				synerr(fname, lineno, "events cannot have module change inside choice")
				break
			if cur_event == null and cur_proxy == null:
				synerr(fname, lineno, "found module change outside an event or proxy")
				break
			line = line.trim_prefix("module").strip_edges().trim_prefix("[")
			var tokens = line.split("]")
			if tokens.size() != 2:
				synerr(fname, lineno, "invalid line [" + line)
				break
				
			var mod_change = EventTypes.Stat_Change.new();
			mod_change.chance_expr = tokens[0].trim_suffix("]").strip_edges()
			var change_part = tokens[1].strip_edges().split(" ")
			mod_change.stat_name = change_part[0].trim_prefix("m_")
			mod_change.change = int(change_part[1])
			if cur_event:
				cur_event.mod_changes.push_back(mod_change)
			else:
				assert(cur_proxy != null)
				cur_proxy.mod_changes.push_back(mod_change)
			
		elif line == "end":
			if cur_choice != null:
				if cur_event:
					cur_event.choices.push_back(cur_choice)
					events[cur_event_key] = cur_event
				else:
					assert(cur_proxy != null)
					cur_proxy.choice = cur_choice
					proxies[cur_event_key] = cur_proxy
			cur_event = null
			cur_proxy = null
			cur_event_key = ""
			cur_choice = null
		
		
	if cur_event != null or cur_proxy != null:
		print("[warning] Not all events were parsed correctly.")
	
	return [events, proxies]



# stats: { String => int }
# mods: { String => Module }
# returns: a number obtained by parsing the expression, which represents
# a 100-based percentage
static func compute_chance_expr(chance_expr: String, stats, mods) -> float:
	if chance_expr.length() == 0:
		return 100.0
		
	# chance_expr can contain:
	#   number
	#   ident (stat name)
	#   operator (+ - *)
	# operators have their usual precedence.
	# == Special Identifier rules ==
	# - If an ident has the form
	#    ident>N   (or >=, <, <=)
	#   it is treated as a boolean 0 or 1
	# - If an ident starts with m_, it is treated as a
	#   module level, rather than a stat value 
#	print("parsing ", chance_expr)
	var tokens = tokenize_chance_expr(chance_expr)
#	debug_print_tokens(tokens)
	
	# FIRST PASS: process mul
	var cur = 0
	var left = NAN
	# list of semi-processed tokens
	var partial = []
	var cur_op = null
	var state = Parser_State.Start
	while cur < len(tokens):
		var token = tokens[cur]
		
		match state:
			Parser_State.Start:
				if is_op(token.type):
					print("[syntax_error] unexpected operator " + str(token.value) + " in stream")
					return 0.0

				left = parse_val(token, stats, mods)
				state = Parser_State.WantOp
				
			Parser_State.WantOp:
				if !is_op(token.type):
					print("[syntax_error] expected operator but got " + str(token.value) + " instead")
					return 0.0
				
				if token.type == Token_Type.Mul:
					cur_op = token.type
					state = Parser_State.WantNotOp
				else:
					partial.push_back(Token.new(Token_Type.Num, left))
					partial.push_back(token)
					state = Parser_State.Start
					
			Parser_State.WantNotOp:
				if is_op(token.type):
					print("[syntax_error] unexpected operator " + str(token.value) + " in stream")
					return 0.0
				
				var val = parse_val(token, stats, mods)
				left *= val
				state = Parser_State.WantOp
				
		cur += 1

	if state == Parser_State.WantNotOp:
		print("[syntax_error] incomplete expression " + chance_expr)
		return 0.0
	else:
		partial.push_back(Token.new(Token_Type.Num, left))
		
#	print("partial:")
#	debug_print_tokens(partial)
	
	# SECOND PASS: process + and -
	cur = 0
	cur_op = null
	state = Parser_State.Start
	while cur < len(partial):
		var token = partial[cur]
		
		match state:
			Parser_State.Start:
				if is_op(token.type):
					print("[syntax_error] unexpected operator " + str(token.value) + " in stream")
					return 0.0

				left = parse_val(token, stats, mods)
				state = Parser_State.WantOp
				
			Parser_State.WantOp:
				if !is_op(token.type):
					print("[syntax_error] expected operator but got " + str(token.value) + " instead")
					return 0.0
				
				assert(token.type != Token_Type.Mul)
				cur_op = token.type
				state = Parser_State.WantNotOp
					
			Parser_State.WantNotOp:
				if is_op(token.type):
					print("[syntax_error] unexpected operator " + str(token.value) + " in stream")
					return 0.0
				
				var val = parse_val(token, stats, mods)
				match cur_op:
					Token_Type.Plus:
						left += val
					Token_Type.Minus:
						left -= val
				state = Parser_State.WantOp
				
		cur += 1

	if state == Parser_State.WantNotOp:
		print("[syntax_error] incomplete expression " + chance_expr)
		return 0.0
		
#	print("final: ", left)
	
	return clamp(left, 0.0, 100.0)


static func is_op(token_type) -> bool:
	return token_type == Token_Type.Plus || \
		token_type == Token_Type.Minus || \
		token_type == Token_Type.Mul


static func parse_val(token: Token, stats, mods) -> float:
	if token.type == Token_Type.Ident:
		var splitters = [">=",">","<=","<"]
		for splitter in splitters:
			var left_right = token.value.split(splitter)
			if len(left_right) == 1: continue
			var actual_ident = left_right[0]
			var val = NAN
			if actual_ident.begins_with("m_"):
				actual_ident = actual_ident.trim_prefix("m_")
				if !mods.has(actual_ident):
					print("[warning] inexisting module ", actual_ident)
					return 0.0
				val = mods[actual_ident].level
			else:
				if !stats.has(actual_ident):
					print("[warning] inexisting stat ", actual_ident)
					return 0.0
				val = float(stats[actual_ident])
			var num = float(left_right[1])
			match splitter:
				">": return float(val > num)
				">=": return float(val >= num)
				"<": return float(val < num)
				"<=": return float(val <= num)
				
		var val = NAN
		if token.value.begins_with("m_"):
			var modname = token.value.trim_prefix("m_")
			if !mods.has(modname):
				print("[warning] inexisting module ", modname)
				return 0.0
			val = mods[token.value].level
		else:
			if !stats.has(token.value):
				print("[warning] inexisting stat ", token.value)
				return 0.0
			val = float(stats[token.value])
		print("[note] ", token.value, " = ", val)
		
		return val
	
	elif token.type == Token_Type.Num:
		return token.value
	
	else:
		assert(false)
		return 0.0
		

enum Parser_State {
	Start,
	WantOp,
	WantNotOp
}
		
enum Token_Type {
	Num, Ident, Plus, Minus, Mul
}

class Token:
	var type # Token_Type
	var value
	
	func _init(ty, val = null):
		self.type = ty
		self.value = val
		
	
static func tokenize_chance_expr(chance_expr: String): # -> [Token]
	var tokens = [] # [Token]
	var cur: int = 0
	var leng: int = chance_expr.length()
	while cur < leng:
		var ch = chance_expr[cur]
		
		if ch.is_valid_float():
			var ret = parse_num(chance_expr, cur)
			tokens.push_back(Token.new(Token_Type.Num, ret[0]))
			cur += ret[1]
		
		elif ch == '+':
			tokens.push_back(Token.new(Token_Type.Plus, "+"))
			cur += 1
		elif ch == '-':
			tokens.push_back(Token.new(Token_Type.Minus, "-"))
			cur += 1
		elif ch == '*':
			tokens.push_back(Token.new(Token_Type.Mul, "*"))
			cur += 1
		
		elif ch == ' ' or ch == '\t' or ch == '\n' or ch == '\r':
			cur += 1
			
		else:
			var ret = parse_ident(chance_expr, cur)
			tokens.push_back(Token.new(Token_Type.Ident, ret[0]))
			cur += ret[1]
	
	return tokens
		
		
# returns [parsed_num, cursor advance]
static func parse_num(s: String, cur: int):
	var accum = float(s[cur])
	var adv = 1
	while cur + adv < s.length():
		var ch = s[cur + adv]
		if !ch.is_valid_float():
			break
		
		accum *= 10
		accum += float(ch)
		adv += 1
			
	return [accum, adv]
	
	
# returns [parsed_ident, cursor advance]
static func parse_ident(s: String, cur: int):
	var ident = s[cur]
	var adv = 1
	while cur + adv < s.length():
		var ch = s[cur + adv]
		if " \t\n\r+-*".find(ch) >= 0:
			break
		
		ident += ch
		adv += 1
			
	return [ident, adv]


static func debug_print_tokens(tokens):
	var names = [
		"TOK_NUM",
		"TOK_IDENT",
		"TOK_PLUS",
		"TOK_MINUS",
		"TOK_MUL"
	]
	for token in tokens:
		print(names[token.type], " ", token.value)

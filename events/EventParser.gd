class_name EventParser

static func parse_all_events(file: File): # -> Dict(name -> Event)
	var events = {}
	# Format:
	#   event event_name # comment is ignored
	#   title Event Title (more than 1 word allowed)
	#   ---
	#   event description (multiline allowed)
	#   ---
	#   > Choice A
	#     [expr] outcome_1
	#     ...
	#     []     outcome_N
	#   > ...
	#   end
	# ...repeats
	var cur_event: EventTypes.Event = null
	var cur_event_key = ""
	var started_desc = false
	var desc = ""
	var cur_choice: EventTypes.Event_Choice = null
	while !file.eof_reached():
		var line = file.get_line()
		
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
			if cur_event != null:
				print("[syntax_error] previous event wasn't ended when read 'event'")
				break
			cur_event = EventTypes.Event.new()
			cur_event_key = line.trim_prefix("event").strip_edges()
			
		elif line.begins_with("title"):
			if cur_event == null:
				print("[syntax_error] found 'title' not belonging to any event")
				break
			cur_event.title = line.trim_prefix("title").strip_edges()
			
		elif line.begins_with("---"):
			assert(!started_desc)
			if cur_event.description.length() > 0:
				print("[syntax_error] event description started more than once")
				break
			started_desc = true
			
		elif line.begins_with(">"):
			if cur_choice != null:
				cur_event.choices.push_back(cur_choice)
			cur_choice = EventTypes.Event_Choice.new()
			cur_choice.description = line.trim_prefix(">").strip_edges()
		
		elif line.begins_with("["):
			if cur_choice == null:
				print("[syntax_error] found outcome line outside a choice")
				break
			line = line.trim_prefix("[")
			var tokens = line.split("]")
			if tokens.size() != 2:
				print("[syntax_error] invalid line [", line)
				break
				
			var outcome = EventTypes.Event_Outcome.new();
			outcome.chance_expr = tokens[0].trim_suffix("]").strip_edges()
			outcome.linked_event = tokens[1].strip_edges()
			cur_choice.outcomes.push_back(outcome)
			
		elif line == "end":
			if cur_choice != null:
				cur_event.choices.push_back(cur_choice)
			events[cur_event_key] = cur_event
			cur_event = null
			cur_event_key = ""
			cur_choice = null
		
		
	if cur_event != null:
		print("[warning] Not all events were parsed correctly.")
	
	return events



# stats: { String => int }
# returns: a number obtained by parsing the expression, which represents
# a 100-based percentage
static func compute_chance_expr(chance_expr: String, stats) -> float:
	# chance_expr can contain:
	#   number
	#   ident (stat name)
	#   operator (+ - *)
	# operators have their usual precedence.
	print("parsing ", chance_expr)
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
					print("[syntax_error] unexpected operator ", token.value, " in stream")
					return 0.0

				left = parse_val(token, stats)
				state = Parser_State.WantOp
				
			Parser_State.WantOp:
				if !is_op(token.type):
					print("[syntax_error] expected operator but got ", token.value, " instead")
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
					print("[syntax_error] unexpected operator ", token.value, " in stream")
					return 0.0
				
				var val = parse_val(token, stats)
				left *= val
				state = Parser_State.WantOp
				
		cur += 1

	if state == Parser_State.WantNotOp:
		print("[syntax_error] incomplete expression ", chance_expr)
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
					print("[syntax_error] unexpected operator ", token.value, " in stream")
					return 0.0

				left = parse_val(token, stats)
				state = Parser_State.WantOp
				
			Parser_State.WantOp:
				if !is_op(token.type):
					print("[syntax_error] expected operator but got ", token.value, " instead")
					return 0.0
				
				assert(token.type != Token_Type.Mul)
				cur_op = token.type
				state = Parser_State.WantNotOp
					
			Parser_State.WantNotOp:
				if is_op(token.type):
					print("[syntax_error] unexpected operator ", token.value, " in stream")
					return 0.0
				
				var val = parse_val(token, stats)
				match cur_op:
					Token_Type.Plus:
						left += val
					Token_Type.Minus:
						left -= val
				state = Parser_State.WantOp
				
		cur += 1

	if state == Parser_State.WantNotOp:
		print("[syntax_error] incomplete expression ", chance_expr)
		return 0.0
		
	print("final: ", left)
	
	return clamp(left, 0.0, 100.0)


static func is_op(token_type) -> bool:
	return token_type == Token_Type.Plus || \
		token_type == Token_Type.Minus || \
		token_type == Token_Type.Mul


static func parse_val(token: Token, stats) -> float:
	if token.type == Token_Type.Ident:
		var splitters = [">=",">","<=","<"]
		for splitter in splitters:
			var left_right = token.value.split(splitter)
			if len(left_right) == 1: continue
			var actual_ident = left_right[0]
			if !stats.has(actual_ident):
				return 0.0
			var num = float(left_right[1])
			match splitter:
				">": return float(stats[actual_ident] > num)
				">=": return float(stats[actual_ident] >= num)
				"<": return float(stats[actual_ident] < num)
				"<=": return float(stats[actual_ident] <= num)
				
		if !stats.has(token.value):
			return 0.0
			
		print("[note] ", token.value, " = ", stats[token.value])
		return stats[token.value]
	
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

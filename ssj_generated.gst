Text = {}

// TODO:  add helpers for common colour names,
// reverse text and bgcolor if I find a way, etc.

// Basic formatting
Text.bold = function (s)
	return "<b>" + s + "</b>"
end function
Text.italic = function (s)
	return "<i>" + s + "</i>"
end function
Text.color = function (c,s)
	return "<color=" + c + ">" + s + "</color>"
end function

String = {}
String.startswith = function (str,pred)
	return str.indexOf(pred) == 0
end function



// Standard error and warning dumps
Error = {}
Error.error = function (s)
	bold = @Text.bold
	color = @Text.color
	print(bold(color("#FF2222","[ERROR] ") + s))
end function

Error.warn = function (s)
		bold = @Text.bold
		color = @Text.color
	print(bold(color("#FFA402","[WARNING] ") + s))
end function



Params = {}

// Parses a list of strings (ARGV), usually `params`, for any 
// command line switches in LST.  Returns a map of any matched
// switches and their arguments, with an extra key named "extra"
// that contains all extra arguments.
Params.parse = function (argv,lst)
	table = { }
	table.extra = []
	
	check_flags = function (arg,lst)
		for v in lst
			if String.startswith(arg,v) then return v
		end for
		return false
	end function
	
	for arg in argv
		match = check_flags(arg,lst)
		if match then 
			table[match] = arg.split("=")[1:].join("=")
		else 
			table.extra.push(arg)
		end if
	end for	

	return table
end function




// Functions for parsing and generating a human-readable config file
// format.  Config.parse reads a config string and returns a map, 
// and Config.dump takes a map and returns a config string.

Config = {}

// Short example of a config string corresponding to this map:
// {"top": {"key": "1", "key2": "2", "nested": {"key": "1", "key2": "2"}}}
// 
// # Lines starting with # or // are ignored.  Blank lines as well.
// 
// # A value by itself indicates a nested map
// top
// 	key  = 1
// 	key2 = 2
// 	nested
// 		key  = 1
// 		key2 = 2
// 	end
// end

// Takes a string to parse (usually from a file) and returns a map
// with nested key/value pairs corresponding to string contents.
Config.parse = function (s)
	_parse = function (lst)
		m = {}
		while lst
			l = lst.pull
			// Ignore comments
			if l.indexOf("#") == 0 then continue
			if l.indexOf("//") == 0 then continue
			// Basic cleanup. Strip whitespace, split by first equal
			l = l.split("=")
			left = l[0].trim
			right = l[1:].join("=").trim
			// Actual parsing
			if left == "" then continue
			if left == "end" then return m
			if right then
				m[left] = right
			else
				m[left] = _parse(lst)
			end if
		end while
		return m
	end function
	return _parse(s.split("
"))
end function

// Takes a map, potentially containing nested maps, and returns
// a string suitable for writing to a file.
Config.dump = function (m,i)
	indent = "	"
	l = []
	if not i then i = 0
	for pair in m
		if typeof(pair.value) == "map" then
			l.push(indent*i + pair.key)
			l.push(Config.dump(pair.value, i+1))
			l.push(indent*i + "end")
		else
			l.push(indent*i + pair.key + " = " + pair.value)
		end if
	end for
	return l.join("
")
end function
///////////////////
// MAP UTILITIES
///////////////////

// TODO:  Map.copy, Map.map_mutate

Map = { }

// Apply function (f) to each element of map (m), returning a new map with
// values applied.  (f) must take a single argument and return a single
// argument.
// 
// Example:
// 
//    double = function (n)
// 	    return n * 2
//    end function
//    map = {"foo":1, "bar":2, "baz":3, "boz":4}
//    print (Map.map(@double,map))

Map.map = function (f, m)
	map = { }
	for pair in m
		map[pair.key] = f(pair.value)
	end for
	return map
end function

// Reduce a map of values (m) to a single value by passing argument pairs
// to transforming function (f).  (f) must accept two arguments and return
// a single argument.  Initially, Map.reduce calls (f) with (acc) plus one
// value from (m); it then continues to call (f) with another value from
// (m) along with the return value of the previous call, until only one
// value remains.
// 
// Example:
// 
//    minus = function (a,b)
//      return a - b
//    end function
//    map = {"foo":1, "bar":2, "baz":3, "boz":4}
//    print(Map.reduce(@minus, 0, map))

Map.reduce = function (f, acc, m)
	for pair in m
		acc = @f(acc,pair.value)
	end for
	return acc
end function

// Filters map (m) via predicate (f).  (f) is a function that takes one
// argument returns TRUE or FALSE.  For every value in (m), if funfion (f)
// returns true, that value is added to a new map.
// 
// Example: 
// 
//    lessthan = function (n)
//      return function (v)
//        return v < n
//      end function
//    end function
//    map = {"foo":1, "bar":2, "baz":3, "boz":4}
//    print(Map.filter(lessthan(3), map))

Map.filter = function (f, m)
	map = {}
	for pair in m
		if f(pair.value) then
			map[pair.key] = pair.value
		end if
	end for
	return map
end function

// Returns true if predicate (p) exists in map (m)
Map.exists = function (p, m)
	return m.hasIndex(p)
end function

////////////////////
// LIST UTILITIES
////////////////////

// TODO: List.copy, List.map_mutate

List = { }

// Apply function (f) to each element of list (l), returning a new list with
// values applied.  (f) must take a single argument and return a single
// argument.
// 
// Example:
// 
//    double = function (n)
// 	    return n * 2
//    end function
//    list = [1, 2, 3, 4]
//    print (List.map(@double,list))

List.map = function (f, l)
	list = []
	for v in l
		list.push(@f(v))
	end for
	return list
end function

// Reduce a list of values (l) to a single value by passing argument pairs
// to transforming function (f) using a left fold.  (f) must accept two
// arguments and return a single argument.  Initially, List.fold_left calls
// (f) with (acc) plus // one value from (l); it then continues to call (f)
// with another value from (l) along with the return value of the previous
// call, until only one value remains.
// 
// Example:
// 
//    minus = function (a,b)
//      return a - b
//    end function
//    list = [1, 2, 3, 4]
//    print(List.fold_left(@minus, 0, list))

List.fold_left = function (f, acc, l)
	for v in l
		acc = f(acc,v)
	end for
	return acc
end function

// Filters list (l) via predicate (f).  (f) is a function that takes one
// argument returns TRUE or FALSE.  For every value in (l), if funfion (f)
// returns true, that value is added to a new list.
// 
// Example:
// 
//    lessthan = function (n)
//      return function (v)
//        return v < n
//      end function
//    end function
//    list = [1, 2, 3, 4]
//    print(List.filter(lessthan(3), list))

List.filter = function (f, l)
	list = []
	for v in l
		if f(v) then
			list.push(v)
		end if
	end for
	return list
end function

// Returns (n) elements from (l).
// Redundant, but exists for consistency with Cons.take and Lazy.take
List.take = function (l,n)
	return l[:n]
end function

// Takes a list (l) and returns a new, reversed list without modifying
// the original.
List.reverse = function (l)
	list = []
	for i in range(l.len - 1, 0)
		list.push(l[i])
	end for
	return list
end function

// Flatten a list of lists (ls).  Elements of (ls) are concatenated
// in the same order to give the result.
// 
// Example:
// 
// List.flatten([[1,2],[3,4],[5,6]])

List.flatten = function (ls)
	list = []
	for l in ls
		list + l
	end for
	return list
end function

// Returns true if predicate (p) exists in list (l)
List.exists = function (p, l)
	for v in l
		if p == v then return true; end if
	end for
	return false
end function

// Returns first value of list (l) that satisfies predicate function (p),
// or null if there is none.
List.find = function (f, l)
	list = []
	for v in l
		if f(v) then
			return v
		end if
	end for
	return null
end function



File = {}

// Search for file in a list of paths given.
File.find = function(f,search)
	computer = get_shell.host_computer
	file = computer.File(f)
	if file then return file
	for i in search
		check = i + "/" + f
		if computer.File(check) then return computer.File(check)
	end for
	Error.error("File not found: " + f) and exit()
end function

File.write = function(f,s)
	computer = get_shell.host_computer
	pwd = computer.current_path
	// Join and re-split the path to make touch happy
	if f[0] == "/" then 
		file = f
	else
		file = pwd + "/" + f
	end if
	filename = file.split("/")[-1]
	filepath = file.split("/")[0:-1].join("/")
	err = computer.touch(filepath,filename)
	if typeof(err) == "string" then Error.warn("touch: " + err + " (" + f + ")") 	
	file = computer.File(f)
	file.set_content(s)
end function

File.delete = function(f)
	file = get_shell.host_computer.File(f)
	if file then file.delete
end function


// Strip file extension
strip_extension = function (s)
	file = s.split(".")
	if file.len == 1 then return s
	return file[0:-1].join(".")
end function


// Using the standard config dir instead of .ssh/config for consistency
// with built-in game tools.
DEFAULT_CONFIG = home_dir + "/Config/ssj.conf"
VERSION = "1.0.2"

print_help = function()
	b = @Text.bold
	bin_name = program_path.split("/")[-1]
	help = []
	help.push(b("Usage: " + bin_name + " [switches] [user[:pass]@]host[:port]
"))
	help.push("

")
	help.push(b("-h	--help				") + "Print this message and exit
")
	help.push(b("-v	--version			") + "Print version information and exit
")
	help.push(b("  	--proto				") + "Protocol to use, defaults to ssh
")
	help.push(b("-J	--jump				") + "Comma-separated list of bounce hosts.
")
	help.push(     "							"  + "Connects to all jumps (last to first)
")
	help.push(     "							"  + "before connecting to destination host.
")
	help.push(b("-F	--conf				") + "Path to config file to use.  Defaults 
")
	help.push(     "							"  + "to ~/Config/ssj.cfg.
")
	help.push(b("-s	--simulate			") + "Simulation mode that skips the actual
")
	help.push(b("  	--sim					") + "connection to hosts.  Useful for
")
	help.push(     "							"  + "testing jump routes before use.
")
	help.push(b("-W	--write_config		") + "Outputs sample configuration file.
")
	help.push(     "							"  + "Uses specified -F path if given, or to
")
	help.push(     "							"  + "~/Config/ssj.cfg if not.
")
	help.push("
")
	print(help.join(""))
	return true
end function

print_version = function()
	color = @Text.color
	bold = @Text.bold
	blue = "#02A2FF"
	gold = "#FFBE4A"
	s = color(blue,bold("ssj")) + " version " + color(blue,bold(VERSION))
	s = s + ", a powered up ssh replacement by " + color(gold,bold("Ilazki")) + "."
	print(s)
	return true
end function

// TODO:  add option to delete logs on jumps?
switch = {}
switch.help    = ["--help", "-h"]
switch.version = ["--version", "-v"]
switch.proto   = ["--proto"] // Protocol to connect via
switch.jump    = ["--jump", "-J"] //Proxy Jump
switch.conf    = ["--conf", "-F"] // Alternate config file
switch.sim     = ["--simulate", "--sim", "-s"] // Print action only
switch.sample  = ["--write_config", "-W"]  // Write sample config file

// TODO:  Add this to Map and List later instead.
join = function (left,right)
	return left+right
end function

valid_switches = Map.reduce(@join,[],switch)

// TODO: add this to Map later.
has_any = function (m,l)
	for key in l
		if m.hasIndex(key) then return key
	end for
	return false
end function

split_login = function (s)
	m       = {}
	_       = s.split("@")
	login   = _[0]
	remote  = _[1:].join("@")
	_       = login.split(":")
	m.user  = _[0]
	m.pass  = _[1:].join(":")
	_       = remote.split(":")
	m.host  = _[0]
	m.port  = _[1:].join(":")
	m.proto = ""
	// If login is only a single name, treat it as host:port  
	// Requires swapping user/host and pass/port in this case 
	// due to how the splits occur.
	if m.host == "" then
		m.host = m.user
		m.user = ""
		m.port = m.pass
		m.pass = ""
	end if
	
	return m
end function

// Write sample config file to f, if provided.  Otherwise
// write to DEFAULT_CONFIG
write_config = function (f)
	name = DEFAULT_CONFIG
	if f then name = f
	print("Writing sample config file to " + name + "...")
	s = []
	s.push("# Lines beginning with # or // are comments and ignored.")
	s.push("")
	s.push("# Hosts are defined in blocks.  A block begins ")
	s.push("# with a name on a line by itself and the word")
	s.push("# 'end' on a line by itself.  Indentation is ")
	s.push("# allowed but optional.")
	s.push("")
	s.push("# Settings are defined with 'key = value' lines")
	s.push("# within a block. All settings except user and ")
	s.push("# host may be omitted. If omitted, ssj will either")
	s.push("# use a default value or (for passwords) prompt")
	s.push("# for input.")
	s.push("# Be aware that names and keys are case-sensitive.")
	s.push("")
	s.push("# To use: ssj example")
	s.push("example")
	s.push("	host  = 127.0.0.1")
	s.push("	user  = foo")
	s.push("	pass  = bar")
	s.push("	port  = 1234")
	s.push("	proto = ssh")
	s.push("	jump = foo,bar,baz")
	s.push("end")
	s.push("")
	s.push("# jump takes a comma-separated list of hosts to")
	s.push("# connect to.  Hosts can either be names in this")
	s.push("# config or hosts in user:pass@host:port format")
	s.push("# Last jump listed is first connected.  Use ")
	s.push("# --simulate to test a jump list before using it.")
	s = s.join("
")
	File.write(name,s)
	return true
end function

// Attempt to get config file from f, if provided. Otherwise
// attempt to use DEFAULT_CONFIG
get_config = function (f)
	name = DEFAULT_CONFIG
	if f then name = f
	file = get_shell.host_computer.File(name)
	if not file then return {}
	return Config.parse(file.content)
end function

// Check config for host and populate any settings
// that aren't explicitly set.
build_host = function (remote,config)
	b = @Text.bold
	merge_config = function(remote, conf)
		has_jump = remote.hasIndex("jump")
		if conf.hasIndex("jump")  and not has_jump       then remote.jump  = conf.jump
		if conf.hasIndex("proto") and remote.proto == "" then remote.proto = conf.proto
		if conf.hasIndex("user")  and remote.user  == "" then remote.user  = conf.user
		if conf.hasIndex("pass")  and remote.pass  == "" then remote.pass  = conf.pass
		if conf.hasIndex("port")  and remote.port  == "" then remote.port  = conf.port
		remote.host = conf.host
		return remote		
	end function

	validate_remote = function(remote)
		if remote.proto == "" then remote.proto = "ssh"
		if remote.port  == "" then remote.port  = "22"
		remote.port = remote.port.to_int
		if typeof(remote.port) != "number" then exit("Invalid port: " + b(remote.port))
		if remote.user == "" then exit("No username supplied for host " + b(remote.host))
		if remote.pass == "" then 
			prompt = "Password for " + remote.user + "@" + remote.host + ":  "
			remote.pass = user_input(prompt)
		end if
		return remote
	end function

	// Merge config and cli args
	if config.hasIndex(remote.host) then 
		remote = merge_config(remote, config[remote.host])
	end if
	// Validation
	remote = validate_remote(remote)
	return remote
end function

// Split and merge a single host with config.
build_split = function(s)
	return build_host(split_login(s),config)	
end function

// Build jump list recursively. Order may be unintuitive, test with --sim
build_jumplist = function(init)
	jumplist = [init]
	i = 0
	while i < jumplist.len
		if jumplist[i].hasIndex("jump") then
			_ = jumplist[i].jump.split(",")	
			jumplist = jumplist + List.map(@build_split, _)
		end if
		i = i + 1
	end while
	jumplist.reverse
	return jumplist
end function

// Connect to JUMP from remote SH
// if SIM is true, don't actually connect, just simulate and print connection chain.
connect_host = function(sh,jump,sim)
	pfx = ""
	b = @Text.bold
	if sim then pfx = b("[SIM] ")
	host_string = [jump.user,"@", jump.host, ":", jump.port].join("")
	msg = [pfx, "Connecting to ", b(host_string), "..."].join("")
	print(msg)
	if not sim then 
		sh = sh.connect_service(jump.host, jump.port, jump.user, jump.pass, jump.proto)
	end if
	if not sh then
		err = [pfx, "Connection to ", b(host_string), " failed. Exiting."].join("")
		exit(err)
	end if
	return sh
end function

// BEGIN MAIN PROGRAM
switches = Params.parse(params,valid_switches)

if has_any(switches,switch.help) then print_help and exit()
if has_any(switches,switch.version) then print_version and exit()

// Get config file and either write sample or load existing.
   c = has_any(switches,switch.conf)
if c then c = switches[c]
if has_any(switches,switch.sample) then write_config(c) and exit()
config = get_config(c)

// Can't operate without a host.
if switches.extra.len < 1 then print_help and exit()

// Parse remote address and populate from switches
remote = split_login(switches.extra[0])
   p = has_any(switches,switch.proto)
if p then remote.proto = switches[p]
   p = has_any(switches,switch.jump)
if p then remote.jump = switches[p]


// The first and possibly only host to connect to.
end_host = build_host(remote,config)

// Build jumplist starting with end_host
jumplist = build_jumplist(end_host)

// Go through jumplist, chaining connections and printing output.
shell = get_shell
sim = has_any(switches,switch.sim)

for j in jumplist
	shell = connect_host(shell,j,sim)
end for

if not sim then shell.start_terminal



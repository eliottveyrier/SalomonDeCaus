extends Node

enum {
	LOG_LEVEL_INFO,
	LOG_LEVEL_ERR
}
@onready var label = %RichTextLabel
@onready var line_edit = %LineEdit
@onready var ui = %UI
signal log(msg : String, level : int)


func _input(event):
	if event.is_action_pressed("toggle_console"):
		ui.visible = !ui.visible


func info(...args):
	var s = ""
	for arg in args:
		s += str(arg)
		s += " "
	log.emit(s, LOG_LEVEL_INFO)

func error(...args):
	var s = ""
	for arg in args:
		s += str(arg)
		s += " "
	log.emit(s, LOG_LEVEL_ERR)

var registered_commands : Dictionary[String,Callable] = {
	"hello" : func (...args): Commands.info("Auf Wiedersehen!!"),
	"help" : func (...args): Commands.list_commands()
}

func list_commands():
	for name in registered_commands:
		info(name)

func register(name, callable):
	registered_commands[name] = callable

func _ready():
	log.connect(_handle_log)
	line_edit.text_submitted.connect(handle_command)

func _handle_log(msg, level):
	label.append_text("\n")
	if level == LOG_LEVEL_ERR:
		label.push_color(Color.RED)
		label.append_text(msg)
		label.pop()
	else:
		label.append_text(msg)



func handle_command(cmd : String):
	print(cmd)
	var split : PackedStringArray = cmd.split(" ")
	if split.is_empty():
		log.emit("empty command", LOG_LEVEL_ERR)
	else:
		var cmd_name = split[0].to_lower()
		if !registered_commands.has(cmd_name):
			log.emit("unregistered command %s" % cmd_name , LOG_LEVEL_ERR)
			return
		var command_function : Callable = registered_commands.get(cmd_name)
		command_function.callv(split.slice(1))
		info("------")
		

extends Control

const INPUT_SETTINGS_PATH := "user://input.cfg"

@export var action_list : Control
var input_button_scene = preload("res://scenes/input_settings_button.tscn")

var waiting_for_action: String = ""
var waiting_event_label: Label

func _ready():
	load_input_map()
	create_action_list()
	
func create_action_list():
	for item in action_list.get_children():
		item.queue_free()
	
	for action in InputMap.get_actions().filter(func(input): return str(input).substr(0, 3) != "ui_"):
		var button : Button = input_button_scene.instantiate()
		var action_label = button.find_child("ActionLabel")
		var icon : TextureRect = button.find_child("Icon")
		var event_label = button.find_child("EventLabel")
		var icon_texture : ControllerIconTexture = icon.texture.duplicate()
		icon_texture.path = action
		action_label.text = action
		icon.texture = icon_texture
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var event : InputEvent = events[0]
			event_label.text = event.as_text()
		else:
			event_label.text = "<Click to bind>"
		action_list.add_child(button)
		button.pressed.connect(_start_remap.bind(action, event_label))

func _start_remap(action: String, label: Label):
	waiting_for_action = action
	waiting_event_label = label
	label.text = "Press any key..."

func input(event):
	if event.is_action_pressed("ui_cancel"):
		$ui.visible = !$ui.visible

func _input(event):
	if waiting_for_action == "":
		input(event)
		return
	# Ignore releases
	if event is InputEventKey and !event.pressed:
		return
	if event is InputEventMouseButton and !event.pressed:
		return
	if event is InputEventJoypadButton and !event.pressed:
		return
	if event is InputEventJoypadMotion:
		if abs(event.axis_value) < 0.5:
			return
		event.axis_value = 1. if event.axis_value >0 else -1
	# Only allow these input types
	if event is InputEventKey \
	or event is InputEventMouseButton \
	or event is InputEventJoypadButton \
	or event is InputEventJoypadMotion:
		# Remove existing bindings
		InputMap.action_erase_events(waiting_for_action)
		# Add new binding
		InputMap.action_add_event(waiting_for_action, event)
		# Update label
		waiting_event_label.text = event.as_text()
		waiting_for_action = ""
		waiting_event_label = null
		accept_event()


func load_input_map():
	var config := ConfigFile.new()
	if config.load(INPUT_SETTINGS_PATH) != OK:
		return
	if !config.has_section("Input"):
		return
	for action in config.get_section_keys("Input"):
		if !InputMap.has_action(action):
			continue
		InputMap.action_erase_events(action)
		var events: Array = config.get_value("Input", action, [])
		for event in events:
			if event is InputEvent:
				InputMap.action_add_event(action, event)


func save_input_map():
	var config := ConfigFile.new()
	for action in InputMap.get_actions():
		config.set_value(
			"Input",
			action,
			InputMap.action_get_events(action)
		)
	config.save(INPUT_SETTINGS_PATH)


func _on_save_button_pressed() -> void:
	save_input_map()


func _on_default_pressed() -> void:
	InputMap.load_from_project_settings()
	create_action_list()

@tool

extends Node


@onready var input: Label = $HBoxContainer/PanelInput/Input
@onready var action: Label = $HBoxContainer/PanelAction/Action

@export var action_input: String : set = _set_action_input
@export var action_name:String: set = _set_action_name

func _ready() -> void:
	input.text = action_input
	action.text = action_name

func _set_action_input(inp: String) -> void:
	action_input = inp
	if Engine.is_editor_hint() && has_node("HBoxContainer/PanelInput/Input"):
		$HBoxContainer/PanelInput/Input.text = inp

func _set_action_name(nm: String) -> void:
	action_name = nm
	if Engine.is_editor_hint() && has_node("HBoxContainer/PanelAction/Action"):
		$HBoxContainer/PanelAction/Action.text = nm

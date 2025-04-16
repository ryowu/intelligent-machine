extends Node2D

var target: Node2D = null
var action_script := """
{
	"target_property": {
		"speed": "200"
	},
	"phase": [
		{
			"loop": "true",
			"action": [
				{
					"type": "move",
					"speed": "200",
					"target_position": "900, 100"
				},
				{
					"type": "invoke",
					"target_method": "shoot",
					"args": "1"
				}
				{
					"type": "sleep",
					"time": "3"
				}
			]
		},
		{
			"phase_index": "1"
		}
	]
}
"""

var is_running = false
var current_action = null

func _process(delta: float) -> void:
	if !current_action:
		current_action = load_next_action()
	
	await perform_action(current_action)
	pass

# Initializes the engine with a target node and an action script.
# @param _target Node2D - The node this engine will act upon.
# @param _action_script String - The full JSON action script
func init_engine(_target: Node2D, _action_script: String):
	target = _target
	action_script = _action_script

func load_next_action():
	pass

func perform_action(action):
	pass

func reset():
	pass

func start():
	is_running = true
	pass

func pause():
	is_running = false
	pass

func stop():
	is_running = false
	reset()
	pass

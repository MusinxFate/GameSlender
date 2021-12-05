extends Label

onready var defaultStamina = get_parent().get_parent().get_parent().get_node("Player").stamina


# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(defaultStamina)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_signalStamina(var stamina):
	text = str(stamina)
	pass # Replace with function body.

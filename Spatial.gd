extends Spatial

onready var forestaudio = get_node("Resources/Forest")

func _ready():
	forestaudio.play()

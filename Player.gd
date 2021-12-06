extends KinematicBody

export var speed = 10
export var fall_acceleration = 50
export var jump_impulse = 20

export var stamina = 100
export var maxStamina = 100
var isRunning = false
var papeis = 0

signal signalStamina

onready var camera : Camera = get_node("CameraOrbit/Camera")
onready var flashlight : SpotLight = get_node("CameraOrbit/Camera/SpotLight")
onready var raycast : RayCast = get_node("CameraOrbit/Camera/RayCast")
onready var staminaCounter : Timer = get_parent().get_node("Resources/StaminaCounter")
onready var recoverStamina : Timer = get_parent().get_node("Resources/RecoverStamina")

var mouseDelta : Vector2 = Vector2()
var minLookAngle : float = -30.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 10.0

var velocity = Vector3.ZERO

func _physics_process(delta):
	var direction = Vector3.ZERO
	var camera_x = camera.global_transform.basis.x
	var camera_z = camera.global_transform.basis.z
	

	if raycast.is_colliding():
		var object = raycast.get_collider()
#		print(object.name)
		if (object.name == "Paper"):
			if Input.is_action_just_pressed("click"):
				papeis += 1
				((object as StaticBody).get_parent() as MeshInstance).visible = false
				object.free()
				if (papeis > 1):
					get_parent().get_node("Resources/Announce").text = str(papeis) + " Papeis Coletados"
				else:
					get_parent().get_node("Resources/Announce").text = str(papeis) + " Papel Coletado"
				get_parent().get_node("Resources/Animations").play("PaperFound")

	if Input.is_action_just_pressed("rightclick"):
		flashlight.visible = !flashlight.visible

	if Input.is_action_just_pressed("sprint"):
		if (stamina < 25 && maxStamina > 25):
			maxStamina -= 5
		running()

	if Input.is_action_just_released("sprint"):
		speed = 10
		isRunning = false
		if (stamina < maxStamina):
			comecarRecuperarStamina()
		staminaCounter.stop()

	if Input.is_action_pressed("movRight"):
		direction += camera_x
	
	if Input.is_action_pressed("movLeft"):
		direction -= camera_x
		
	if Input.is_action_pressed("movDown"):
		direction += camera_z
	
	if Input.is_action_pressed("movUp"):
		direction -= camera_z

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	velocity.y -= fall_acceleration * (delta)
	velocity = move_and_slide(velocity, Vector3.UP)

func running():
	if (stamina > 10):
		isRunning = true
		speed = 20
		staminaCounter.start()
	else:
		isRunning = false
		speed = 10
		comecarRecuperarStamina()

func _ready():
	recoverStamina.set_wait_time(2)
	pass # Replace with function body.

func _process(delta):
	# rotate the camera along the x axis
	camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	# clamp camera x rotation axis
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	
#	raycast.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	
#	raycast.rotation_degrees.x = clamp(raycast.rotation_degrees.x, minLookAngle, maxLookAngle)
	
#	print(str(raycast.rotation_degrees.x) + "raycast")
#	print(str(camera.rotation_degrees.x) + "camera")
	
	# rotate the player along their y-axis
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta

	# reset the mouseDelta vector
	mouseDelta = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative


func _on_StaminaCounter_timeout():
	stamina -= 10
	if (stamina < 10):
		isRunning = false
		comecarRecuperarStamina()
		speed = 10
		staminaCounter.stop()
	emit_signal("signalStamina", stamina)

func comecarRecuperarStamina():
	recoverStamina.start()

func _on_RecoverStamina_timeout():
	if (!isRunning && (stamina < maxStamina)):
		if (stamina + 2 > maxStamina):
			stamina = maxStamina
		else:
			stamina += 2
		emit_signal("signalStamina", stamina)
	else:
		recoverStamina.stop()

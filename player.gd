extends CharacterBody3D

#Sprite References
@onready var sprite_base: Node3D = $SpriteBase
@onready var sprite: AnimatedSprite3D = $SpriteBase/PlayerSprite
@onready var front: Marker3D = $SpriteBase/PlayerSprite/Front

#Camera references
@onready var camera_base: Node3D = $CameraBase
@onready var spring_arm: SpringArm3D = $CameraBase/SpringArm
@onready var camera: Camera3D = $CameraBase/SpringArm/Camera


##Current state of character
@export var current_state : StringName
##Camera's Sensitivity
@export var sens : float = 0.2
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	#Set current_state to idle, is explained why further down
	current_state = &"Idle"
	#Lock mouse 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	#Camera rotation
	if event is InputEventMouseMotion:
		camera_base.rotate_y(deg_to_rad(-event.relative.x * sens))
		spring_arm.rotate_x(deg_to_rad(-event.relative.y * sens))
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _physics_process(delta: float) -> void:
	#Esc to quit 
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	sprite_rotation()

func sprite_rotation():
	#These variables are for animation snyc, for example:
	#A run anim is playing, 12 frames long, if direction changes from F to FL,
	#Anim does not reset back to frame 0, but continues to next frame.
	var current_frame = sprite.get_frame()
	var current_progress = sprite.get_frame_progress()
	
	#Variables that get the forward direction of the camera and player. 
	#The forward direction of the player is the Marker3D that is a child of 
	#the sprite. 
	#The left var is to check when to flip the sprite
	var c_fwd = -camera.global_transform.basis.z
	var fwd = -front.global_transform.basis.z
	var left = sprite.global_transform.basis.x
	
	#Dot products of the left and foward direction. Checks how in inline
	#the camera's forward dir is with the left and foward dir of the sprite.
	#This can be used to determine the direction of the sprite.
	var l_dot = left.dot(c_fwd)
	var f_dot = fwd.dot(c_fwd)
	print(f_dot)
	sprite.flip_h = false
	
	#This is the actual script that determines the direction of the sprite relative to the camera.
	
	#The floats that are checked will vary based on sprite size and camera distance,
	#so change to whatever works best for your use case
	
	#current_state can be changed based on what state the player is in, eg: idle, Run, Jump, then
	#in here that animation will play, (if it exists).
	
	
	##Behind direction
	if f_dot < -0.8:
		sprite.play(current_state+&"B")
		sprite.set_frame_and_progress(current_frame, current_progress)
	##Forward direction
	elif f_dot > 0.8:
		sprite.play(current_state+&"F")
		sprite.set_frame_and_progress(current_frame, current_progress)
	##If neither behind or in front, must be left and diagonal directions.
	else:
		##This flips the sprite if passing the left threshold. This just to cut back
		##on 8 different assets for the player
		sprite.flip_h = l_dot > 0
		
		##Left/Right direction
		if abs(f_dot) < 0.5:
			sprite.play(current_state+&"L")
			sprite.set_frame_and_progress(current_frame, current_progress)
		##BackLeft/BackRight direction
		elif f_dot < 0.25:
			sprite.play(current_state+&"BL")
			sprite.set_frame_and_progress(current_frame, current_progress)
		else:
		##FrontLeft/BackLeft direction
			sprite.play(current_state+&"FL")
			sprite.set_frame_and_progress(current_frame, current_progress)
		



extends KinematicBody

onready var camera = get_node("Camera")
onready var ground = get_node("RayCast")
onready var fps = get_node("FPS")

const viewrange = 4096
var rely=0
var relx=0
const gravity=-0.5
var falling=0
var walk=false
var mult=1
var movement = Vector3(0,0,0)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ground.add_exception(self)
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	get_node("Sprite").set_pos(Vector2(OS.get_window_size().x/2,OS.get_window_size().y/2))
	fps.set_text("FPS: "+var2str(OS.get_frames_per_second()))
	rotate_y(relx*delta*0.1)
	camera.rotate_x(rely*delta*0.1)
	relx=0
	rely=0
	if(get_rotation().z==0):
		mult=1
	else:
		mult=-1
	
	if(Input.is_key_pressed(KEY_W)):
		movement.z=-delta*4
	elif(Input.is_key_pressed(KEY_S)):
		movement.z=delta*2
	if(Input.is_key_pressed(KEY_A)):
		movement.x=-delta*2
	if(Input.is_key_pressed(KEY_D)):
		movement.x=delta*2
	if(Input.is_key_pressed(KEY_SHIFT)):
		movement.z*=1.5
		movement.x*=1.5
	if(Input.is_key_pressed(KEY_SPACE)&&ground.is_colliding()):
		falling=0.1
	elif(ground.is_colliding()||is_colliding()):
		falling=0
	else:
		falling+=gravity*delta
	movement = Vector3(0,falling,0)+(get_transform().basis*movement)
	move(movement)
	if(is_colliding()):
		var collnorm=get_collision_normal()
		movement=collnorm.slide(movement)
		move(movement)
	
	movement=Vector3(0,0,0)

func _input(event):
	if(event.type == InputEvent.MOUSE_MOTION):
		relx=event.relative_x
		rely=event.relative_y
	if(event.type == InputEvent.MOUSE_BUTTON):
		if(event.pressed==true && event.button_index==BUTTON_LEFT):
			get_parent().spawnBullet(get_transform(), get_translation()+camera.get_translation(), camera.get_rotation().x)
		elif(event.pressed==true && event.button_index==BUTTON_RIGHT):
			camera.set_perspective(39,0.1,viewrange)
		elif(event.pressed==false && event.button_index==BUTTON_RIGHT):
			camera.set_perspective(60,0.1,viewrange)

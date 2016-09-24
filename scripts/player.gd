
extends KinematicBody

onready var camera = get_node("Camera")
onready var ground = get_node("RayCast")
onready var fps = get_node("FPS")
onready var vcoll = get_node("Camera/VehicleRay")
onready var structures = get_parent().get_node("Structures")
var currentvehicle

const viewrange = 4096
var rely=0
var relx=0
const gravity=-0.5
var falling=0
var walk=false
var mult=1
var movement = Vector3(0,0,0)
var vehicle = false

func _ready():
	set_transform(get_node("/root/global").spawn)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ground.add_exception(self)
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	get_node("Sprite").set_pos(Vector2(OS.get_window_size().x/2,OS.get_window_size().y/2))
	get_node("WaterBlue").set_scale(Vector2(OS.get_window_size().x,OS.get_window_size().y))
	if(get_translation().y<(3-1.9)):
		get_node("WaterBlue").show()
	else:
		get_node("WaterBlue").hide()
	fps.set_text("FPS: "+var2str(OS.get_frames_per_second()))
	
	if(vehicle==false):
		walk(delta)
	if(vehicle==false && vcoll.is_colliding()):
		if(vcoll.get_collider().has_node("WheelFR")||vcoll.get_collider().has_node("BuildingMesh")):
			get_node("Label").show()
		if(vcoll.get_collider().has_node("WheelFR") && Input.is_key_pressed(KEY_F)): #Enter the vehicle
			currentvehicle=vcoll.get_collider()
			currentvehicle.get_node("Camera").make_current()
			set_collision_mask(0)
			vehicle=true
		elif(vcoll.get_collider().has_node("BuildingMesh")&& Input.is_key_pressed(KEY_F)): #Edit the current building
			get_node("/root/global").spawn=get_transform()
			structures.check_edited(vcoll.get_collider())
			get_tree().change_scene("res://scenes/building.tscn")
	else:
			get_node("Label").hide()
	
	if(vehicle==true):
		#Accel:
		if(Input.is_key_pressed(KEY_W)):
			currentvehicle.set_engine_force(40)
		elif(Input.is_key_pressed(KEY_S)):
			currentvehicle.set_engine_force(-40)
		else:
			currentvehicle.set_engine_force(0)
		
		#Steering:
		if(Input.is_key_pressed(KEY_A)&&currentvehicle.get_steering()>-0.5):
			currentvehicle.set_steering(currentvehicle.get_steering()-delta*0.3)
		elif(Input.is_key_pressed(KEY_D)&&currentvehicle.get_steering()<0.5):
			currentvehicle.set_steering(currentvehicle.get_steering()+delta*0.3)
		else:
			currentvehicle.set_steering(currentvehicle.get_steering()-sign(currentvehicle.get_steering())*delta)

		#Exit vehicle
		if(Input.is_key_pressed(KEY_R)):
			set_translation(currentvehicle.get_translation()+Vector3(0,3,0))
			vehicle=false
			currentvehicle.set_engine_force(0)
			set_collision_mask(2)
			camera.make_current()


func walk(delta):
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
		if(event.pressed==true && event.button_index==BUTTON_LEFT && vehicle==false):
			get_parent().spawnBullet(get_transform(), get_translation()+camera.get_translation(), camera.get_rotation().x)
		elif(event.pressed==true && event.button_index==BUTTON_RIGHT):
			camera.set_perspective(39,0.1,viewrange)
		elif(event.pressed==false && event.button_index==BUTTON_RIGHT):
			camera.set_perspective(60,0.1,viewrange)

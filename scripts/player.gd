extends KinematicBody

var relx = 0 #Relative mouse movement in x direction
var rely = 0 #Relative mouse movement in y direction
var sensitivity = 0.1
var movement = Vector3(0,0,0)
var gravity = -0.5
var falling = 0
var driving = false
var current_vehicle

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Ground.add_exception(self)
	$Camera/InteractRay.add_exception(self)
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	$FPS.set_text("FPS: "+var2str(Engine.get_frames_per_second()))
	
	rotate_y(-relx*delta*sensitivity)
	$Camera.rotate_x(-rely*delta*sensitivity)
	
	movement=Vector3(0,0,0)
	if(driving==false):
		#Show interaction hint
		if($Camera/InteractRay.is_colliding() && $Camera/InteractRay.get_collider().is_in_group("interactive")):
			$Label.show()
		else:
			$Label.hide()
		
		if(Input.is_key_pressed(KEY_W)):
			movement.z=-delta*4
		elif(Input.is_key_pressed(KEY_S)):
			movement.z=delta*2
		if(Input.is_key_pressed(KEY_A)):
			movement.x=-delta*2
		if(Input.is_key_pressed(KEY_D)):
			movement.x=delta*2
		if(Input.is_key_pressed(KEY_SHIFT)):
			movement.x*=1.5
			movement.z*=1.5
		if(Input.is_key_pressed(KEY_SPACE)&&$Ground.is_colliding()):
			falling=0.1
		elif($Ground.is_colliding()||is_colliding()):
			falling=0
		else:
			falling+=gravity*delta
		if(Input.is_key_pressed(KEY_F)&&$Label.is_visible()):
			$Label.hide()
			current_vehicle = $Camera/InteractRay.get_collider()
			add_collision_exception_with(current_vehicle) #Disable collision
			current_vehicle.enabled=true
			driving=true
		
		movement = Vector3(0, falling, 0)+(get_transform().basis*movement)
		move(movement)
		if(is_colliding()):
			movement=movement.slide(get_collision_normal())
			move(movement)
	
	else:
		set_translation(current_vehicle.get_node("Driver").get_global_transform().origin)
		if(Input.is_key_pressed(KEY_R)):
			current_vehicle.enabled=false
			driving=false
			remove_collision_exception_with(current_vehicle) #Enable collision, throws player out of the vehicle
			#TODO: Exit the vehicle in a more controlled way
	
	relx=0
	rely=0


func _input(event):
	if(event.type == InputEvent.MOUSE_MOTION):
		relx=event.relative_x
		rely=event.relative_y
	elif(event.type == InputEvent.MOUSE_BUTTON):
		if(event.pressed==true && event.button_index==BUTTON_LEFT):
			pass
		elif(event.pressed==true && event.button_index==BUTTON_RIGHT):
			$Camera.set_perspective(39,0.1,3000)
		elif(event.pressed==false && event.button_index==BUTTON_RIGHT):
			$Camera.set_perspective(60,0.1,3000)
		

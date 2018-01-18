extends KinematicBody

var relx = 0 #Relative mouse movement in x direction
var rely = 0 #Relative mouse movement in y direction
var sensitivity = 0.1
var movement = Vector3(0,0,0)
var gravity = -20
var falling = 0
var driving = false
var current_vehicle
var walk_speed=150
var parent

func _ready():
	parent=get_parent()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Ground.add_exception(self)
	$Camera/InteractRay.add_exception(self)
	set_physics_process(true)
	set_process_input(true)

func _physics_process(delta):
	$FPS.set_text("FPS: "+var2str(Engine.get_frames_per_second()))
	
	rotate_y(-relx*delta*sensitivity)
	$Camera.rotate_x(-rely*delta*sensitivity)
	
	movement=Vector3(0,0,0)
	if(driving==false):
		# ==interaction hint==
		if($Camera/InteractRay.is_colliding() && $Camera/InteractRay.get_collider().is_in_group("interactive")):
			$Label.show()
		else:
			$Label.hide()
		
		# ==Basic movement==
		if(Input.is_key_pressed(KEY_W)): #Forward
			movement.z=-delta*walk_speed
		if(Input.is_key_pressed(KEY_S)): #Backwards
			movement.z=delta*walk_speed
		if(Input.is_key_pressed(KEY_A)): #Left
			movement.x=-delta*walk_speed
		if(Input.is_key_pressed(KEY_D)): #Right
			movement.x=delta*walk_speed
		if(Input.is_key_pressed(KEY_SHIFT)): #Run faster
			movement.x*=2
			movement.z*=2
		
		# ==Jumping, falling and climbing==
		if(Input.is_key_pressed(KEY_SPACE)&&$Ground.is_colliding()):
			falling=7
		elif($Ground.is_colliding()||is_on_floor()):
			falling=0
		else:
			falling+=gravity*delta
		#Check if climbing is possible:
		for coll in get_slide_count():
			if(get_slide_collision(coll).get_collider().is_in_group("ladder")):
				if(Input.is_key_pressed(KEY_W)):
					falling=4
				elif(Input.is_key_pressed(KEY_SHIFT)):
					falling=-3
				else:
					falling=0
		
		movement = Vector3(0, falling, 0)+(get_transform().basis*movement)
		move_and_slide(movement)
		
		if(Input.is_key_pressed(KEY_F)&&$Label.is_visible()):
			$Label.hide()
			current_vehicle = $Camera/InteractRay.get_collider()
			add_collision_exception_with(current_vehicle) #Disable collision
			current_vehicle.enabled=true
			driving=true
			get_parent().remove_child(self)
			current_vehicle.add_child(self)
			set_translation(current_vehicle.get_node("Driver").get_translation())
			set_rotation(Vector3(0,PI,0))

		
	else:
		if(Input.is_key_pressed(KEY_R)):
			current_vehicle.enabled=false
			driving=false
			remove_collision_exception_with(current_vehicle) #Enable collision, throws player out of the vehicle
			#TODO: Exit the vehicle in a more controlled way
			get_parent().remove_child(self)
			parent.add_child(self)
			set_rotation(Vector3(0, PI+current_vehicle.get_rotation().y, 0))
			set_translation(current_vehicle.get_node("Driver").get_global_transform().origin)
	
	relx=0
	rely=0


func _input(event):
	if(event is InputEventMouseMotion):
		relx=event.relative.x
		rely=event.relative.y
	elif(event is InputEventMouseButton):
		if(event.pressed==true && event.button_index==BUTTON_LEFT):
			pass
		elif(event.pressed==true && event.button_index==BUTTON_RIGHT):
			$Camera.set_perspective(39,0.1,3000)
		elif(event.pressed==false && event.button_index==BUTTON_RIGHT):
			$Camera.set_perspective(60,0.1,3000)
		

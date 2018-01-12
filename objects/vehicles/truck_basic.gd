extends VehicleBody

var enabled=false

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if(enabled==true):
		#Accel:
		if(Input.is_key_pressed(KEY_W)):
			set_brake(0)
			set_engine_force(500)
		elif(Input.is_key_pressed(KEY_S)):
			set_brake(0)
			set_engine_force(-200)
		elif(Input.is_key_pressed(KEY_SPACE)):
			set_brake(1)
		else:
			set_engine_force(0)
			set_brake(0)
			
		#Steering:
		if(Input.is_key_pressed(KEY_A)&&get_steering()<0.3):
			set_steering(get_steering()+delta*0.3)
		elif(Input.is_key_pressed(KEY_D)&&get_steering()>-0.3):
			set_steering(get_steering()-delta*0.3)
		else:
			set_steering(get_steering()-sign(get_steering())*delta)
	elif(get_brake()!=1&&get_engine_force()!=0):
		set_brake(1)
		set_engine_force(0)

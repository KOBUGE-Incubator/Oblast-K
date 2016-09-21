
extends KinematicBody

var gravity  = -0.5

var tf
var rot
var fallspeed = 0
const bulletspeed = 100
var impacted = false

func _ready():
	set_fixed_process(true)

func direction(trans, rotation):
	tf=trans
	rot=rotation

func _fixed_process(delta):
	if(!is_colliding()):
		move(tf.basis*Vector3(0,fallspeed+sin(rot)*bulletspeed*delta,-cos(rot)*bulletspeed*delta))
	elif(impacted==false):
		impacted=true
		get_node("CollisionShape").set_scale(Vector3(0,0,0))
		look_at(get_translation()+get_collision_normal(), Vector3(1,1,0))
		get_node("TestCube").hide()
		get_node("Impact").rotate_z(randf())
		get_node("Impact").show()
	fallspeed+=gravity*delta
func _on_Timer_timeout():
	queue_free()

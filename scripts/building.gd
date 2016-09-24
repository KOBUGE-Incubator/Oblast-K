extends Spatial

var tile = load("res://scenes/buildingtile.tscn")
onready var root = get_node("/root/global")
var current=false
var xsize=4
var ysize=2
var device_nr=0

func _ready():
	set_fixed_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("ConstructCamera").make_current()
	
	print(root.devices[root.curr_index])
	var x=0
	var y=0
	while(x<xsize):
		while(y<ysize):
			var node=tile.instance()
			node.set_translation(Vector3(5*x,0.1,5*y))
			if(root.devices[root.curr_index][2*x+y]==1):
				node.get_node("TestCube").show()
				device_nr+=1
			add_child(node)
			y+=1
		y=0
		x+=1

func _fixed_process(delta):
	get_node("Label").set_text("Devices: " + var2str(device_nr))
	if(Input.is_key_pressed(KEY_R)):
		get_tree().change_scene("res://scenes/world.tscn")

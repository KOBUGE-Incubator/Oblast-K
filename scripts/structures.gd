extends Spatial

var devices = []
onready var root = get_node("/root/global")

func _ready():
	if(root.devices.size()==0): #Initialize when no data available
		for child in get_children():
			devices.push_back([0,0,0,0,0,0,0,0])
			root.devices=devices
	else: #Load data else
		devices=root.devices
	
	var i = 0
	for child in get_children():
		var x=0
		while(x<8):
			if(devices[i][x]==1):
				var node = TestCube.new()
				node.set_translation(Vector3(2.5+5*(x-(x%2))/2, 0, 2.5+5*(x%2)))
				child.add_child(node)
			x+=1
		i+=1

func check_edited(structure):
	for child in get_children():
		if(structure==child):
			get_node("/root/global").curr_index = child.get_index()
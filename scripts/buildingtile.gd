extends StaticBody

onready var root = get_node("/root/global")

func _ready():
	pass

func _input_event(camera, event, click_pos, click_normal, shape_idx):
	if(event.type == InputEvent.MOUSE_BUTTON):
		if(event.pressed==true && event.button_index==BUTTON_LEFT):
			if(get_node("TestCube").is_hidden()):
				get_node("TestCube").show()
				root.devices[root.curr_index][2*get_translation().x/5+get_translation().z/5]=1
				get_parent().device_nr+=1
			else:
				get_node("TestCube").hide()
				root.devices[root.curr_index][2*get_translation().x/5+get_translation().z/5]=0
				get_parent().device_nr-=1
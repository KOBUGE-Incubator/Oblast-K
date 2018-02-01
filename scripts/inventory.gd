extends Control

var itemdef = ConfigFile.new()
var current_name
var current_desc
var current_edible
var current_image
var current_object

func _ready():
	var err = itemdef.load("res://objects/itemdef.def")
	if(err==OK):
		var items
		for items in itemdef.get_sections():
			add_item(items)
	else:
		print("Could not parse item definition.")
	
	adapt_gui_to_window()

func add_item(name):
	$LeftPanel/ItemList.add_item(name)

#Show actions when item is selected
#TODO: Handle case where one single, deselected item can't be selected any more
func _on_ItemList_item_selected( index ):
	current_name   = $LeftPanel/ItemList.get_item_text(index)
	current_desc   = itemdef.get_value(current_name, "description")
	current_edible = itemdef.get_value(current_name, "edible")
	current_image  = itemdef.get_value(current_name, "image")
	current_object = itemdef.get_value(current_name, "object")
	
	$LeftPanel/ActionPanel/NameLabel.set_text(current_name)
	$LeftPanel/ActionPanel/DescLabel.bbcode_text = current_desc
	$LeftPanel/ActionPanel.show()

#Hide actions when no item is selected
func _on_ItemList_nothing_selected():
	$LeftPanel/ActionPanel.hide()

#Resizes all GUI elements to fit the window size
func adapt_gui_to_window():
	var screensize = OS.window_size
	#GUI to window size:
	set_margin(MARGIN_BOTTOM, screensize.y)
	set_margin(MARGIN_RIGHT, screensize.x)
	#Left panel to 1/3rd window size:
	$LeftPanel.set_margin(MARGIN_RIGHT, screensize.x/3)
	#Inventory to half left panel size:
	$LeftPanel/ItemList.set_margin(MARGIN_RIGHT, screensize.x/6)
	$LeftPanel/Label.set_margin(MARGIN_RIGHT, screensize.x/6)
	#Action panel to half left panel size -10 px
	$LeftPanel/ActionPanel.set_margin(MARGIN_LEFT, screensize.x/6+10)
	#Right top panel to 1/3rd window size:
	$RightTopPanel.set_margin(MARGIN_LEFT, 2*screensize.x/3)

func _on_EquipButton_pressed():
	if($RightTopPanel/HandPanel/HandLabel.text != "Empty"):
		add_item($RightTopPanel/HandPanel/HandLabel.text)
	$RightTopPanel/HandPanel/HandLabel.set_text(current_name)
	$RightTopPanel/HandPanel/HandSprite.texture = load(current_image)
	_on_DestroyAlert_confirmed()
	$RightTopPanel/HandPanel/UnequipButton.disabled = false
	get_parent().get_node("Camera/Hand").remove_child(get_parent().get_node("Camera/Hand").get_child(0)) #Only one child present
	get_parent().get_node("Camera/Hand").add_child(load(current_object).instance())

func _on_UnequipButton_pressed():
	$RightTopPanel/HandPanel/UnequipButton.disabled = true
	add_item($RightTopPanel/HandPanel/HandLabel.text)
	$RightTopPanel/HandPanel/HandLabel.text = "Empty"
	$RightTopPanel/HandPanel/HandSprite.texture = null
	get_parent().get_node("Camera/Hand").remove_child(get_parent().get_node("Camera/Hand").get_child(0)) #Only one child present

#Popup when trying to destroy an item
func _on_DestroyButton_pressed():
	$DestroyAlert.popup_centered()

#Remove item when destruction it is confirmed
func _on_DestroyAlert_confirmed():
	$LeftPanel/ItemList.remove_item($LeftPanel/ItemList.get_selected_items()[0])
	$LeftPanel/ActionPanel.hide()

func _on_EatButton_pressed():
	if(current_edible > 0):
		_on_DestroyAlert_confirmed()
		var hunger = $RightTopPanel/Stats/Hunger.value
		if(hunger+current_edible>100):
			$RightTopPanel/Stats/Hunger.value = 100
		else:
			$RightTopPanel/Stats/Hunger.value = hunger+current_edible


extends Spatial

onready var bullet = preload("res://scenes/bullet.tscn")
var shot=false
var tf

func _ready():
	pass

func spawnBullet(trf,trn,rot):
	var node=bullet.instance()
	node.set_translation(trn)
	node.direction(trf,rot)
	add_child(node)
	shot=true

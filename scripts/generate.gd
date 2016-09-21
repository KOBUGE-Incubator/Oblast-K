
extends Spatial

onready var mesh = Mesh.new()

onready var tree = preload("res://scenes/tree.tscn")
var res = load("res://textures/map.png").get_data()

var posx=0
var posy=0

var gridsize=1

func _ready():
	print(res)
	generate_terrain(4,0,1024)

func generate_terrain(gridsize, min_distance, max_distance):
	var surfTool = SurfaceTool.new()
	surfTool.begin(VS.PRIMITIVE_TRIANGLES)
	posx=0
	while(posx<res.get_width()):
		posy=0
		while(posy<res.get_height()):
			randomTree(posx, posy)
			#1st half
			surfTool.add_uv(Vector2(0,0))
			surfTool.add_vertex(Vector3(posx, height_value(posx, posy), posy))
			surfTool.add_uv(Vector2(1,0))
			surfTool.add_vertex(Vector3(posx+gridsize, height_value(posx+gridsize, posy), posy))
			surfTool.add_uv(Vector2(1,1))
			surfTool.add_vertex(Vector3(posx+gridsize, height_value(posx+gridsize, posy+gridsize), posy+gridsize))

			#2nd half
			surfTool.add_uv(Vector2(1,1))
			surfTool.add_vertex(Vector3(posx+gridsize, height_value(posx+gridsize, posy+gridsize), posy+gridsize))
			surfTool.add_uv(Vector2(0,1))
			surfTool.add_vertex(Vector3(posx, height_value(posx, posy+gridsize), posy+gridsize))
			surfTool.add_uv(Vector2(0,0))
			surfTool.add_vertex(Vector3(posx, height_value(posx, posy), posy))
			posy+=gridsize
		posx+=gridsize
	posx=0
	surfTool.generate_normals()
	surfTool.index()
	surfTool.commit(mesh)
	set_mesh(mesh)
	create_trimesh_collision()
	get_child(get_child_count()-1).set_layer_mask(3) #A big hack.

func height_value(x, y):
	if(x<0||y<0||x>=res.get_width()||y>=res.get_height()):
		return -1
	else:
		return res.get_pixel(x,y).v*20

func randomTree(x, y):
	if(randi()%20)==0:
		var node=tree.instance()
		node.rotate_y(randf())
		node.set_translation(Vector3(x,height_value(x,y),y))
		add_child(node)
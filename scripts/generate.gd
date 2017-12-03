
extends Spatial

var heightmapimg = Image.new()
var heightmap

var posx=0
var posy=0

var width = 256
var height = 256


func _ready():
	heightmapimg.load("res://scenery/map2.png")
	heightmap=heightmapimg.get_data()
	
	generate_terrain(1, 3, 256, 256)

func generate_terrain(gridsize, steps, dim, size):
	var mesh = Mesh.new()
	var tile = MeshInstance.new()
	var surfTool = SurfaceTool.new()
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	posx=0
	while(posx<width):
		posy=0
		while(posy<height):
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

func height_value(x, y):
	#return get_height(x, y) # This will result in an unsmoothed terrain. Leave here for debugging purposes.
	var smoothHeight = 0
	smoothHeight += get_height(x-1, y-1)
	smoothHeight += get_height(x-1, y)
	smoothHeight += get_height(x-1, y+1)
	smoothHeight += get_height(x, y-1)
	smoothHeight += get_height(x, y)
	smoothHeight += get_height(x, y+1)
	smoothHeight += get_height(x+1, y-1)
	smoothHeight += get_height(x+1, y)
	smoothHeight += get_height(x+1, y+1)
	return (smoothHeight/9)

func get_height(x, y):
	if(x>=width):
		return get_height(0,y)
	if(y>=height):
		return get_height(x,0)
	return heightmap[4*(width*y+x)]/10-5.1

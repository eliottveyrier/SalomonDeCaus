extends Polygon2D

@export var tip : Vector2
@export var pyramid_height_pct : float = 0.2

var _tip : Vector2
var _rect : Rect2
var _center : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(polygon)
	## initialize _rect to the rect "given" by the 4 points
	#region _rect init
	var a = polygon[0]
	var b = polygon[1]
	var c = polygon[2]
	
	var w = b.x - a.x
	var h = c.y - b.y
	_rect = Rect2(a.x, a.y, w, h)
	#endregion
	_center = _rect.get_center()
	## Clean up the polygon
	var p = polygon
	p.clear()
	polygon = p
	## update
	print(polygon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_tip = tip.rotated(Time.get_ticks_msec()/1000.)
	_tip = tip * (1+sin(2.52651351321351 * Time.get_ticks_msec()/1000. + 5.598181651))
	make_polygon()
	

func make_polygon():
	
	var light_dir = (_center - _tip).normalized()
	var perp = Vector2(-light_dir.y, light_dir.x)
	var left = _rect.get_support(-perp)
	var right = _rect.get_support(perp)
	var d = (_center - _tip).length() / 75.
	
	var depth_scale = 1.0 / max(d, 0.01)
	var half_shadow_width = (_rect.size.length() * 0.5) * depth_scale
	
	var shoulders = _center + (_tip-_center) * (1.-pyramid_height_pct)
	var left_shoulder = shoulders - perp * half_shadow_width
	var right_shoulder = shoulders + perp * half_shadow_width
	
	var p = PackedVector2Array()
	p.append(left)
	p.append(left_shoulder)
	p.append(_tip)
	p.append(right_shoulder)
	p.append(right)
	
	polygon = p
	

extends Sprite2D

var active = true

func _activate():
	active = true

func _disable():
	active = false
	for i in range(3):
		OscSettings.broadcastf(
			"/oscControl/miniGame/player/"+str(i+1)+"/cercle",
			0.)

func _ready():
	for _area in $Areas.get_children():
		var area = _area as HarmonicArea
		area.body_entered.connect(_on_area_entered.bind(area.index))
		area.body_exited.connect(_on_area_exited.bind(area.index))

func _on_area_entered(body,index : int):
	if body is Game6Player:
		body.current_index = index
		OscSettings.broadcastf(
			"/oscControl/miniGame/6/player/"+str(body.player_number)+"/cercle",
			float(index))

func _on_area_exited(body,index : int):
	if body is Game6Player:
		if index == body.current_index:
			body.current_index = -1
			OscSettings.broadcastf(
			"/oscControl/miniGame/6/player/"+str(body.player_number)+"/cercle",
			0.)

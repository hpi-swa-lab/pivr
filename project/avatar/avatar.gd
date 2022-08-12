extends Spatial

func may_airwrite():
	return $FPController/RightHandController/MeshInstance/CursorSelector.above_max_distance()

func may_place_cursors():
	return !$FPController/airwrite.is_writing()

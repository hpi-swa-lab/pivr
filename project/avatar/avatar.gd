extends Spatial

func may_airwrite():
	return $FPController/RightHandController/MeshInstance/CursorSelector.above_max_distance()

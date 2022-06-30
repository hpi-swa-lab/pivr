extends Label


var contents setget set_contents

func set_contents(aString):
	contents = aString
	text = contents

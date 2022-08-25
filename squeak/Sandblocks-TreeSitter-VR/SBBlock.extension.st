Extension { #name : #SBBlock }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBBlock >> changed [

	super changed.
	self triggerEvent: #SBchanged
]

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBBlock >> exportStructure [

	^ {
		#children -> #().
		#class -> #generic.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#id -> self vrId.
		#vrInteractionAllowed -> false.
		#color -> Color white asHTMLColor.
		#type -> #none} as: Dictionary
]

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBBlock >> vrId [

	^ self valueOfProperty: #vrId ifAbsentPut: [| id |
		id := SBVREditor current getNextId.
		SBVREditor current registerMorph: self atVrId: id.
		id]
]

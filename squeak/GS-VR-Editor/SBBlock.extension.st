Extension { #name : #SBBlock }

{ #category : #'*GS-VR-Editor' }
SBBlock >> changed [

	super changed.
	self triggerEvent: #SBchanged
]

{ #category : #'*GS-VR-Editor' }
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

{ #category : #'*GS-VR-Editor' }
SBBlock >> vrId [

	^ self valueOfProperty: #vrId ifAbsentPut: [| id |
		id := SBVREditor current getNextId.
		SBVREditor current registerMorph: self atVrId: id.
		id]
]

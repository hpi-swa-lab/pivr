Extension { #name : #Morph }

{ #category : #'*GS-VR-Editor' }
Morph >> exportStructure [

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
Morph >> shouldBeInVr [

	^ false
]

{ #category : #'*GS-VR-Editor' }
Morph >> vrId [

	^ self valueOfProperty: #vrId ifAbsentPut: [| id |
		id := SBVREditor current getNextId.
		SBVREditor current registerMorph: self atVrId: id.
		id]
]

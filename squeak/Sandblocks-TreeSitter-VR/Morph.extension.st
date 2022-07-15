Extension { #name : #Morph }

{ #category : #'*Sandblocks-TreeSitter-VR' }
Morph >> vrId [

	^ self valueOfProperty: #vrId ifAbsentPut: [| id |
		id := SBVREditor current getNextId.
		SBVREditor current registerMorph: self atVrId: id.
		id]
]

Extension { #name : #SBCursorText }

{ #category : #'*GS-VR-Editor' }
SBCursorText >> exportInfo [

	^ {
		#type -> 'text'.
		#textId -> self textMorph vrId.
		#index -> cursorIndex.
	} as: Dictionary
]

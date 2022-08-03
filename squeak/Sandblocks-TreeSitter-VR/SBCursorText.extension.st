Extension { #name : #SBCursorText }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBCursorText >> exportInfo [

	^ {
		#type -> 'text'.
		#textId -> self textMorph vrId.
		#index -> cursorIndex.
	} as: Dictionary
]

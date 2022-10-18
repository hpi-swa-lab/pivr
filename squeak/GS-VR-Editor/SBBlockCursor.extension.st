Extension { #name : #SBBlockCursor }

{ #category : #'*GS-VR-Editor' }
SBBlockCursor >> exportInfo [

	cursorPosition class = SBCursorText ifFalse: [^ nil].
	^ {
		#textId -> cursorPosition textMorph vrId.
		#index -> cursorPosition textMorph cursor.
	} as: Dictionary
]

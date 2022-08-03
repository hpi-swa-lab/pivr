Extension { #name : #SBBlockCursor }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBBlockCursor >> exportInfo [

	cursorPosition class = SBCursorText ifFalse: [^ nil].
	^ {
		#textId -> cursorPosition textMorph vrId.
		#index -> cursorPosition textMorph cursor.
	} as: Dictionary
]

Extension { #name : #SBTSStMethod }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBTSStMethod >> exportStructure [

	| previous |
	previous := nil.
	^ {
		#children -> (Array streamContents: [:stream |
			self
				cursorPositionsDo: [:pos |
					self visibleSubmorphsDo: [:morph |
						stream nextPut: morph exportStructure]]
				shallow: true]).
		#class -> #block.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#id -> self vrId.
		#color -> self drawnColor asHTMLColor.
		#type -> 'methodRoot'.
		#vrInteractionAllowed -> false} as: Dictionary
]
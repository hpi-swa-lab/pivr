Extension { #name : #SBTSStMethod }

{ #category : #'*GReaSe-Components-BlockCode' }
SBTSStMethod >> childrenAsCodeBlocks [

	^ Array streamContents: [:stream |
		self visibleSubmorphsDo: [:morph |
			stream nextPut: morph asCodeBlock]]
]

{ #category : #'*GReaSe-Components-BlockCode' }
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
		#color -> self drawnColor asHTMLColor.
		#type -> 'methodRoot'.
		#vrInteractionAllowed -> false} as: Dictionary
]

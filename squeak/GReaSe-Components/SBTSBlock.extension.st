Extension { #name : #SBTSBlock }

{ #category : #'*GReaSe-Components-BlockCode' }
SBTSBlock >> asCodeBlock [

	^ CodeBlock new
		key: GRReact nextGodotId;
		sandblock: self
]

{ #category : #'*GReaSe-Components-BlockCode' }
SBTSBlock >> childrenAsCodeBlocks [

	^ Array streamContents: [:stream |
			self cursorPositionsDo: [:pos |
				pos isText ifTrue: [
					stream nextPut: pos textMorph asCodeBlock].
				
				(pos isSelect and: [pos block ~= self]) ifTrue: [
					stream nextPut: pos block asCodeBlock]]
				shallow: true]
]

{ #category : #'*GReaSe-Components-BlockCode' }
SBTSBlock >> exportStructure [

	| previous |
	previous := nil.
	^ {
		#children -> (Array streamContents: [:stream |
			self
				cursorPositionsDo: [:pos |
					"pos isInsert ifTrue: [stream nextPut: ({#class -> #insert. #bounds -> (pos bounds in: [:r | {r left. r top. r width. r height}]). #horizontal -> pos hasHorizontalLayout. #type -> pos command element type} as: Dictionary)]."
					pos isText ifTrue: [stream nextPut: pos textMorph exportStructure].
					(pos isSelect and: [pos block ~= self]) ifTrue: [
						previous ifNotNil: [(pos block factory hardLineBreakBetween: previous and: pos block) ifTrue: [stream nextPut: ({#class -> #hardLineBreak} as: Dictionary)]].
						stream nextPut: pos block exportStructure.
						previous := pos block]]
				shallow: true]).
		#class -> #block.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#type -> self type.
		#highlight -> self highlight.
		#color -> self drawnColor asHTMLColor.
		"for now, interactions are only properly implemented for blocks that inherit from SBTSBlock and some kinds of text"
		#vrInteractionAllowed -> ((self isUnknown not) and: [self floating or: [self parentSandblock isKindOf: SBTSBlock]])} as: Dictionary
]

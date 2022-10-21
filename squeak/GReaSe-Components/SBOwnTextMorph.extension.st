Extension { #name : #SBOwnTextMorph }

{ #category : #'*GReaSe-Components-BlockCode' }
SBOwnTextMorph >> asCodeBlock [

	^ CodeBlockText new
		key: GRReact nextGodotId;
		morph: self
]

{ #category : #'*GReaSe-Components-BlockCode' }
SBOwnTextMorph >> exportStructure [

	^ {
		#class -> #text.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#contents -> self contents.
		#color -> self color asHTMLColor.
		#vrInteractionAllowed -> false} as: Dictionary
]

Extension { #name : #SBBlock }

{ #category : #'*GReaSe-Components-BlockCode' }
SBBlock >> asCodeBlock [

	^ CodeBlock new
		key: self;
		sandblock: self
]

{ #category : #'*GReaSe-Components-BlockCode' }
SBBlock >> exportStructure [

	^ {
		#children -> #().
		#class -> #generic.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#vrInteractionAllowed -> false.
		#color -> Color white asHTMLColor.
		#type -> #none} as: Dictionary
]

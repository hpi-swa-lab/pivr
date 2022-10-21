Extension { #name : #SBTSTextMorph }

{ #category : #'*GReaSe-Components-BlockCode' }
SBTSTextMorph >> exportStructure [

	^ {
		#class -> #text.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#regex -> ([self slot firstNode regexString] ifError: ['']).
		#contents -> self contents.
		#color -> self color asHTMLColor.
		#vrInteractionAllowed -> true} as: Dictionary
]

Extension { #name : #SBOwnTextMorph }

{ #category : #'*GS-VR-Editor' }
SBOwnTextMorph >> exportStructure [

	^ {
		#class -> #text.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#contents -> self contents.
		#color -> self color asHTMLColor.
		#id -> self vrId.
		#vrInteractionAllowed -> false} as: Dictionary
]

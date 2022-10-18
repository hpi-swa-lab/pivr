Extension { #name : #SBUnknown }

{ #category : #'*GS-VR-Editor' }
SBUnknown >> exportStructure [

	"mostly copied from SBTSBlock"
	| previous |
	previous := nil.
	^ {
		#children -> #().
		#class -> #block.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#type -> ''.
		#id -> self vrId.
		#highlight -> ''.
		#color -> self drawnColor asHTMLColor.
		#vrInteractionAllowed -> false} as: Dictionary
]

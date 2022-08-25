Extension { #name : #SBTSInputReconcile }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBTSInputReconcile >> exportStructure [

	^ super exportStructure
		addAll: {
			#type -> #genericRoot.
			#color -> Color blue asHTMLColor.};
		yourself
]

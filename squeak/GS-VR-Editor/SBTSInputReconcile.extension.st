Extension { #name : #SBTSInputReconcile }

{ #category : #'*GS-VR-Editor' }
SBTSInputReconcile >> exportStructure [

	^ super exportStructure
		addAll: {
			#type -> #genericRoot.
			#color -> Color blue asHTMLColor.};
		yourself
]

Extension { #name : #CMFReactComponent }

{ #category : #'*GReaSe-Core' }
CMFReactComponent >> godot: aClassName [

	^ CMFReactNodeGodot new
		godotClass: aClassName;
		yourself
]

Extension { #name : #CMFReactComponent }

{ #category : #'*GReaSe-Core' }
CMFReactComponent >> godot: aClassName [

	^ CMFReactNodeGodot new
		godotClass: aClassName;
		yourself
]

{ #category : #'*GReaSe-Core' }
CMFReactComponent >> useProvided: aSymbol [

	| hook react |
	react := CMFCurrentReact value.
	hook := react getHook: GRHookUseProvided IfAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			yourself].
	^ hook getValueBasedOnNodeTree: react elementTree setLastValue: true
]

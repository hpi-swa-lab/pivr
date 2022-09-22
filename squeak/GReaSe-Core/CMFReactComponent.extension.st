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
	hook := react getHook: GRHookUseProvided IfAbsent: [:nodeId |
		GRHookUseProvided new
			symbol: aSymbol nodeId: nodeId;
			yourself].
	^ hook getValueBasedOnNodeTree: react elementTree setLastValue: true
]

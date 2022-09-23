Extension { #name : #CMFReactComponent }

{ #category : #'*GReaSe-Core' }
CMFReactComponent >> godot: aClassName [

	^ GRReactNodeGodot new
		godotClass: aClassName;
		yourself
]

{ #category : #'*GReaSe-Core' }
CMFReactComponent class >> inGodot [
	"replaces the current listener and opens a new one, serving this component class as the root"

	^ GDSocketListener start: self
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

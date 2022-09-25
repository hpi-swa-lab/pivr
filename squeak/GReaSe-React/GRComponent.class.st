Class {
	#name : #GRComponent,
	#superclass : #CMFReactComponent,
	#category : #'GReaSe-React'
}

{ #category : #deploy }
GRComponent class >> inGodot [
	"replaces the current listener and opens a new one, serving this component class as the root"

	^ GRSocketListener start: self
]

{ #category : #deploy }
GRComponent class >> start [

	self inGodot.
	GRReact startGodot
]

{ #category : #deploy }
GRComponent class >> startQuest [

	self inGodot.
	GRReact questRestartApp
]

{ #category : #constructors }
GRComponent >> godot: aClassName [

	^ GRReactNodeGodot new
		godotClass: aClassName;
		yourself
]

{ #category : #hooks }
GRComponent >> useControllerTransform [

	^ self useProvided: #controllerTransform
]

{ #category : #hooks }
GRComponent >> useGripPressed [

	^ (self useProvided: #pressedButtons) includes: 6
]

{ #category : #hooks }
GRComponent >> useHandPortal [

	^ self useProvided: #handPortal
]

{ #category : #hooks }
GRComponent >> useHeadTransform [

	^ self useProvided: #headTransform
]

{ #category : #hooks }
GRComponent >> useProvided: aSymbol [

	| hook react |
	react := CMFCurrentReact value.
	hook := react getHook: GRHookUseProvided IfAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			yourself].
	^ hook getValueBasedOnNodeTree: react elementTree setLastValue: true
]

{ #category : #hooks }
GRComponent >> useProvidedRef: aSymbol [

	| hook react |
	react := CMFCurrentReact value.
	hook := react getHook: GRHookUseProvidedRef IfAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			yourself].
	^ hook
]

{ #category : #hooks }
GRComponent >> useWorldPortal [

	^ self useProvided: #worldPortal
]

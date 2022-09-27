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

{ #category : #hooks }
GRComponent class >> useProvided: aSymbol [

	| hook react |
	react := CMFCurrentReact value.
	hook := react getHook: GRHookUseProvided IfAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			yourself].
	^ hook getValueBasedOnNodeTree: react elementTree setLastValue: true
]

{ #category : #hooks }
GRComponent class >> useProvided: aSymbol namespace: anotherSymbol [

	| hook react |
	react := CMFCurrentReact value.
	hook := react getHook: GRHookUseProvided IfAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			namespace: anotherSymbol;
			yourself].
	hook namespace: anotherSymbol.
	^ hook getValueBasedOnNodeTree: react elementTree setLastValue: true
]

{ #category : #hooks }
GRComponent class >> useProvidedRef: aSymbol [

	| hook react |
	react := CMFCurrentReact value.
	hook := react getHook: GRHookUseProvidedRef IfAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			yourself].
	^ hook
]

{ #category : #hooks }
GRComponent class >> useProvidedRef: aSymbol namespace: anotherSymbol [

	| hook react |
	react := CMFCurrentReact value.
	hook := react getHook: GRHookUseProvidedRef IfAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			namespace: anotherSymbol;
			yourself].
	hook namespace: anotherSymbol.
	^ hook
]

{ #category : #constructors }
GRComponent >> godot: aClassName [

	^ GRReactNodeGodot new
		godotClass: aClassName;
		yourself
]

{ #category : #hooks }
GRComponent >> useAreaWithIntersectionFor: aBlock [

	| intersected entered exited |
	intersected := self useState: false.
	entered := self
		useCallback: [:node | (aBlock value: node) ifTrue: [intersected set: true]]
		dependencies: {aBlock}.
	exited := self
		useCallback: [:node | (aBlock value: node) ifTrue: [intersected set: false]]
		dependencies: {aBlock}.
	^ {
		(self godot: #Area)
			area_entered: entered;
			area_exited: exited.
		intersected get}
]

{ #category : #hooks }
GRComponent >> useControllerTransform [

	^ self useProvided: #controllerTransform
]

{ #category : #hooks }
GRComponent >> useGripPressed [

	^ (self useProvided: #pressedButtons) includes: ControllerInfoDworph grip
]

{ #category : #hooks }
GRComponent >> useHandId [

	^ self useProvided: #handId
]

{ #category : #hooks }
GRComponent >> useHandIsFree [

	^ self useProvided: #handIsFree
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

	^ self class useProvided: aSymbol
]

{ #category : #hooks }
GRComponent >> useProvided: aSymbol namespace: anotherSymbol [

	^ self class useProvided: aSymbol namespace: anotherSymbol
]

{ #category : #hooks }
GRComponent >> useProvidedRef: aSymbol [

	^ self class useProvidedRef: aSymbol
]

{ #category : #hooks }
GRComponent >> useProvidedRef: aSymbol namespace: anotherSymbol [

	^ self class useProvidedRef: aSymbol namespace: anotherSymbol
]

{ #category : #hooks }
GRComponent >> useTeleport [

	^ self useProvided: #teleport
]

{ #category : #hooks }
GRComponent >> useTriggerPressedDo: aBlock [

	| trigger ready |
	trigger := self useTriggerStrength.
	ready := self useRef: true.
	self
		useEffect: [
			(trigger > 0.6 and: [ready get]) ifTrue: [
				ready set: false.
				aBlock value].
			trigger = 0.0 ifTrue: [ready set: true]]
		dependencies: {aBlock. trigger}
]

{ #category : #hooks }
GRComponent >> useTriggerStrength [

	^ self useProvided: #trigger
]

{ #category : #hooks }
GRComponent >> useWorldPortal [

	^ self useProvided: #worldPortal
]

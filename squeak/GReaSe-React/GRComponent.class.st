Class {
	#name : #GRComponent,
	#superclass : #CMFReactComponent,
	#category : #'GReaSe-React'
}

{ #category : #accessing }
GRComponent class >> appDescription [

	^ DworphicApplicationDescription new
		name: self name;
		render: [self new]
]

{ #category : #deploy }
GRComponent class >> start [

	self startWithArguments: (GRReact debugCollisionShapes
		ifTrue: [#('--debug-collisions')]
		ifFalse: [#()])
]

{ #category : #deploy }
GRComponent class >> startIn: aProjectFolderString [

	| scenePath |
	self startListener.
	
	scenePath := aProjectFolderString, '/GRRoot/GRRoot.tscn'.
	(FSReference / scenePath) exists ifFalse: [GRReact pivrPath / 'project' / 'GRRoot' copyAllTo: FSReference / aProjectFolderString / 'GRRoot'].
	GRReact
		startGodotWithArguments: {aProjectFolderString, '/GRRoot/GRRoot.tscn'}
		in: aProjectFolderString
]

{ #category : #deploy }
GRComponent class >> startListener [
	"replaces the current listener and opens a new one, serving this component class as the root"

	^ GRSocketListener start: self
]

{ #category : #deploy }
GRComponent class >> startQuest [

	self startListener.
	GRReact questRestartApp
]

{ #category : #deploy }
GRComponent class >> startWithArguments: aStringCollection [

	self startListener.
	GRReact startGodotWithArguments: {GRReact port asString}, aStringCollection
]

{ #category : #deploy }
GRComponent class >> toolIcon [

	^ #dworph
]

{ #category : #helpers }
GRComponent >> animate: aSymbol of: anObject to: aValue [
	"can specifiy duration, transition, and ease on the returned object"

	^ GRAnimation new
		object: anObject;
		value: aValue;
		property: aSymbol
]

{ #category : #helpers }
GRComponent >> cubeOfSize: aVector3OrNumber color: aColor [

	^ GDCollisionShape new
		shape: (GDBoxShape new extents: aVector3OrNumber asVector3 / 2.0);
		children: (self cubeVisualOfSize: aVector3OrNumber color: aColor)
]

{ #category : #helpers }
GRComponent >> cubeVisualOfSize: aVector3OrNumber color: aColor [

	^ GDMeshInstance new mesh: (GDCubeMesh new
		size: aVector3OrNumber asVector3;
		material: (GDSpatialMaterial new albedoColor: aColor))
]

{ #category : #helpers }
GRComponent >> directionFromScancode: aNumber [

	| dir |
	dir := nil.
	aNumber = GDGlobalConstants keyW ifTrue: [dir := 0 @ 0 @ -1].
	aNumber = GDGlobalConstants keyS ifTrue: [dir := 0 @ 0 @ 1].
	aNumber = GDGlobalConstants keyA ifTrue: [dir := -1 @ 0 @ 0].
	aNumber = GDGlobalConstants keyD ifTrue: [dir := 1 @ 0 @ 0].
	aNumber = GDGlobalConstants keyE ifTrue: [dir := 0 @ 1 @ 0].
	aNumber = GDGlobalConstants keyQ ifTrue: [dir := 0 @ -1 @ 0].
	^ dir
]

{ #category : #helpers }
GRComponent >> every: aNumberInSeconds do: aBlock [

	^ GDTimer new
		autostart: true;
		waitTime: aNumberInSeconds;
		onTimeout: aBlock
]

{ #category : #constructors }
GRComponent >> godot: aClassName [

	^ GRReactNodeGodot new
		godotClass: aClassName;
		yourself
]

{ #category : #helpers }
GRComponent >> in: aNumberInSeconds do: aBlock [

	^ GDTimer new
		autostart: true;
		oneShot: true;
		waitTime: aNumberInSeconds;
		onTimeout: aBlock
]

{ #category : #helpers }
GRComponent >> nextGodotId [

	^ GRReact nextGodotId
]

{ #category : #helpers }
GRComponent >> sendKeyEvent: aBlock [

	GDInputEventKey externalNewDuring: [:inputEvent |
		aBlock value: inputEvent.
		GDInput instance parseInputEvent: inputEvent]
]

{ #category : #helpers }
GRComponent >> sphereOfRadius: aNumber color: aColor [

	^ GDCollisionShape new
		shape: (GDSphereShape new radius: aNumber);
		children: {self sphereVisualOfRadius: aNumber color: aColor}
]

{ #category : #helpers }
GRComponent >> sphereVisualOfRadius: aNumber color: aColor [

	^ GDMeshInstance new mesh: (GDSphereMesh new
		radius: aNumber;
		height: aNumber * 2;
		material: (GDSpatialMaterial new albedoColor: aColor))
]

{ #category : #hooks }
GRComponent >> useActiveEventHandlersFor: areaRef side: aSymbol transform: aMatrix controller: controllerRef type: aTypeSymbol [

	| createInteractiveEvent createInteractiveButtonEvent transformRef grabbedHandlers activeEventHandlers buttonHandlers createButtonHandler createInteractiveAxisEvent |
	grabbedHandlers := self useState: nil.
	
	transformRef := self useRef: aMatrix.
	transformRef set: aMatrix.
	
	createInteractiveEvent := [:handlers |
		GRInteractiveAreaEvent new
			controllerRef: controllerRef;
			side: aSymbol;
			type: aTypeSymbol;
			transform: transformRef get;
			targetHandlers: handlers;
			grabState: grabbedHandlers;
			grabRelease: [:releaseHandlers |
				(releaseHandlers at: #onBlur) ifNotNil: [:block | block cull: (createInteractiveEvent value: releaseHandlers)].
				activeEventHandlers set: [:old | old copyRemove: releaseHandlers]]].
	createInteractiveButtonEvent := [:button :handlers | ((createInteractiveEvent value: handlers) as: GRInteractiveAreaEventButton) button: button].
	createInteractiveAxisEvent := [:axis :strength :handlers |
		((createInteractiveEvent value: handlers) as: GRInteractiveAreaEventAxis)
			axis: axis;
			strength: strength].
	
	activeEventHandlers := self
		useRegisterHandArea: areaRef
		grabbed: grabbedHandlers
		create: createInteractiveEvent.
	buttonHandlers := self useProvided: #buttonHandlers.
	
	createButtonHandler := [:event |
		[:button |
			buttonHandlers get
				at: aSymbol
				ifPresent: [:list | list do: [:h | (h get at: event) cull: (createInteractiveButtonEvent value: button value: nil)]].
			(grabbedHandlers get ifNotNil: [:g | {g}] ifNil: [activeEventHandlers get]) do: [:handlers | (handlers at: event) ifNotNil: [:block | block cull: (createInteractiveButtonEvent value: button value: handlers)]]]].
	^ Dictionary new
		at: #onButtonPress put: (createButtonHandler value: #onButtonPress);
		at: #onButtonRelease put: (createButtonHandler value: #onButtonRelease);
		at: #onAxisChange put: [:axis :strength |
			buttonHandlers get
				at: aSymbol
				ifPresent: [:list | list do: [:h | (h get at: #onAxisChange) cull: (createInteractiveAxisEvent value: axis value: strength value: nil)]].
			(grabbedHandlers get ifNotNil: [:g | {g}] ifNil: [activeEventHandlers get]) do: [:handlers | (handlers at: #onAxisChange) ifNotNil: [:block | block cull: (createInteractiveAxisEvent value: axis value: strength value: nil)]]];
		yourself
]

{ #category : #hooks }
GRComponent >> useApplication: aBlock dependencies: aCollection [

	| openApplication closeApplication appDesc |
	appDesc := self useMemo: aBlock dependencies: aCollection.
	openApplication := self useProvided: #openApplication.
	closeApplication := self useProvided: #closeApplication.
	self
		useEffect: [ | id |
			id := openApplication value: appDesc.
			[closeApplication value: id]]
		dependencies: {appDesc}
]

{ #category : #hooks }
GRComponent >> useAreaWithIntersectionFor: aBlock dependencies: aCollection [

	| intersected entered exited block |
	intersected := self useState: false.
	block := self useCallback: aBlock dependencies: aCollection.
	entered := self
		useCallback: [:node | (block value: node) ifTrue: [intersected set: true]]
		dependencies: {block}.
	exited := self
		useCallback: [:node | (block value: node) ifTrue: [intersected set: false]]
		dependencies: {block}.
	^ {
		(self godot: #Area)
			area_entered: entered;
			area_exited: exited.
		intersected get}
]

{ #category : #hooks }
GRComponent >> useButtonPress: aPressBlock release: aReleaseBlock axisChange: anAxisBlock side: aSymbol [

	| ref evalIfSideCorrect eventReceivers |
	eventReceivers := self useProvided: #eventReceivers.
	evalIfSideCorrect := [:block |
		[:event |
			(aSymbol isNil or: [event side = aSymbol])
				ifTrue: [block cull: event]]].
	ref := self useRef: Dictionary new.
	ref get at: #onButtonPress put: (evalIfSideCorrect value: aPressBlock).
	ref get at: #onButtonRelease put: (evalIfSideCorrect value: aReleaseBlock).
	ref get at: #onAxisChange put: (evalIfSideCorrect value: anAxisBlock).
	
	self
		useEffect: [
			eventReceivers get add: ref.
			[eventReceivers get remove: ref]]
		dependencies: #()
]

{ #category : #hooks }
GRComponent >> useControlledState: aBlock default: aCollection [
"TODO extract params name automatically by implementing wrapper around useState"

	| argumentNames states |
	argumentNames := aBlock method propertyValueAt: #cmfArgumentNames ifAbsent: [ | node |
		node := Parser new
			parse: aBlock sourceString
			class: UndefinedObject
			noPattern: true
			notifying: nil
			ifFail: nil.
		aBlock method propertyValueAt: #cmfArgumentNames put: (node body statements first expr arguments
			collect: #name
			as: Array)].
	
	states := argumentNames collect: [:name | self useState: (aCollection at: name)].
	
	self
		useVoiceIntents: (states
			with: argumentNames
			collect: [:state :name | {'set ', name, ' (?P<arg>.*)' -> [:params | state set: (params at: 'arg')]}])
		key: self className.
	
	^ aBlock valueWithArguments: states
]

{ #category : #hooks }
GRComponent >> useForceUpdate [

	| n |
	n := self useState: 0.
	^ [n set: [:old | old + 1]]
]

{ #category : #hooks }
GRComponent >> useGodotRef [

	^ CMFCurrentReact value useGodotRef
]

{ #category : #hooks }
GRComponent >> useHeadTransform [

	^ self useProvided: #headTransform
]

{ #category : #hooks }
GRComponent >> useProvided: aSymbol [

	^ CMFCurrentReact value useProvided: aSymbol
]

{ #category : #hooks }
GRComponent >> useProvided: aSymbol namespace: anotherSymbol [

	^ CMFCurrentReact value useProvided: aSymbol namespace: anotherSymbol
]

{ #category : #hooks }
GRComponent >> useProvidedRef: aSymbol [

	^ CMFCurrentReact value useProvidedRef: aSymbol
]

{ #category : #hooks }
GRComponent >> useProvidedRef: aSymbol namespace: anotherSymbol [

	^ CMFCurrentReact value useProvidedRef: aSymbol namespace: anotherSymbol
]

{ #category : #hooks }
GRComponent >> useRegisterHand: handRef [

	| handLocks |
	handLocks := self useProvided: #handLocks.
	self useEffect: [
		handLocks get at: handRef put: nil.
		[handLocks get removeKey: handRef]]
		dependencies: #()
]

{ #category : #hooks }
GRComponent >> useRegisterHandArea: areaRef grabbed: grabbedHandlers create: createInteractiveEvent [

	| activeEventHandlers addHandAreaHandlers removeHandAreaHandlers |
	activeEventHandlers := self useState: OrderedCollection new.
	addHandAreaHandlers := self useProvided: #addHandAreaHandlers.
	removeHandAreaHandlers := self useProvided: #removeHandAreaHandlers.
	self
		useEffect: [
			addHandAreaHandlers value: areaRef get value: (Dictionary withAll: {
				#onAreaEntered -> [:eventHandlers |
					grabbedHandlers get ifNil: [
						(eventHandlers at: #onHover) ifNotNil: [:block | block cull: (createInteractiveEvent value: eventHandlers)].
						activeEventHandlers set: [:old | old copyWith: eventHandlers]]].
				#onAreaExited -> [:eventHandlers |
					grabbedHandlers get ifNil: [
						(eventHandlers at: #onBlur) ifNotNil: [:block | block cull: (createInteractiveEvent value: eventHandlers)].
						activeEventHandlers set: [:old | "deliberately allowing this to not remove anything: if we had a grab we may try to unsubscribe twice"
						old copyWithout: eventHandlers]]]}).
			[removeHandAreaHandlers value: areaRef get]]
		dependencies: #().
	^ activeEventHandlers
]

{ #category : #hooks }
GRComponent >> useSceneInstance: aScenePath [

	| scene |
	scene := self
		useMemo: [ | gameScene |
			gameScene := GRReactCurrentSession value loadResource: aScenePath.
			(GDPackedScene basicNew objectId: gameScene objectId) instance]
		dependencies: {}.
	^ GDNode new call: 'add_child' arguments: {scene}
]

{ #category : #hooks }
GRComponent >> useUpdatingRef: anObject [

	| ref |
	ref := self useRef: nil.
	ref set: anObject.
	^ ref
]

{ #category : #hooks }
GRComponent >> useViewportTextureContaining: aCollectionofNodes size: aPoint [

	| viewportTex |
	viewportTex := self useState: nil.
	^ {
		GDViewport new
			size: aPoint;
			renderTargetVFlip: true;
			renderTargetUpdateMode: GDViewport updateAlways;
			subscribeCall: 'get_texture' with: #() do: [:tex | viewportTex set: tex];
			children: aCollectionofNodes.
		GDSpatialMaterial new
			flagsUnshaded: true;
			flagsAlbedoTexForceSrgb: true;
			albedoTexture: viewportTex get;
			resourceLocalToScene: true}
]

{ #category : #hooks }
GRComponent >> useWorldPortal [

	^ self useProvided: #worldPortal
]

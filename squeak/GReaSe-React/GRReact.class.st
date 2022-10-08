Class {
	#name : #GRReact,
	#superclass : #CMFReact,
	#instVars : [
		'pendingUpdates',
		'callbacks',
		'server',
		'session',
		'pendingRefs',
		'waitingRefs',
		'changesBlock'
	],
	#classVars : [
		'CurrentGodotId',
		'GodotPath',
		'RunningGodotProcess'
	],
	#category : #'GReaSe-React'
}

{ #category : #deploy }
GRReact class >> current [

	^ GRSocketListener current
]

{ #category : #testing }
GRReact class >> isValidRenderResult: anObject [

	^ anObject isGodotNode or: [anObject isSequenceable and: [anObject allSatisfy: [:o | o isGodotNode]]]
]

{ #category : #utils }
GRReact class >> nextGodotId [

	CurrentGodotId ifNil: [CurrentGodotId := 0].
	CurrentGodotId := CurrentGodotId + 1.
	CurrentGodotId > 900000000 ifTrue: [CurrentGodotId := 0].
	^ CurrentGodotId
]

{ #category : #deploy }
GRReact class >> pivrPath [

	^ SquotWorkingCopy registered
		detect: [:each | | gitRepository |
			(each repository respondsTo: #git) and: [
				gitRepository := each repository git.
				each repository remoteNames anySatisfy: [:remote | (gitRepository remoteUrl: remote) includesSubstring: 'pivr']]]
		ifFound: [:project | project repository git workingDir]
]

{ #category : #deploy }
GRReact class >> questRestartApp [

	(Smalltalk classNamed: #OSProcess) ifNotNil: [:shell |
		shell waitForCommand: 'adb reverse tcp:8292 tcp:8292'.
		shell waitForCommand: 'adb shell am force-stop org.godotengine.vrandsqueaktest'.
		shell waitForCommand: 'adb shell am start -n org.godotengine.vrandsqueaktest/com.godot.game.GodotApp']
]

{ #category : #'as yet unclassified' }
GRReact class >> resetGodotId [

	CurrentGodotId := 0
]

{ #category : #deploy }
GRReact class >> startGodotWithArguments: aStringCollection [

	(Smalltalk classNamed: #OSProcess) ifNotNil: [:shell |
		RunningGodotProcess ifNotNil: [
			RunningGodotProcess class caseOf: {
				[ExternalUnixOSProcess] -> [RunningGodotProcess terminate].
				[ExternalWindowsOSProcess] -> [RunningGodotProcess threads do: [:thread | thread terminate]]}].
		GodotPath ifNil: [GodotPath := UIManager default request: 'Path to godot executable?'].
		RunningGodotProcess := shell isWindows
			ifTrue: [OSProcess command: ('{1} --path {2} {3}' format: {
				GodotPath.
				(self pivrPath / 'project') asString.
				aStringCollection joinSeparatedBy: ' '})]
			ifFalse: [
				ExternalUnixOSProcess
					forkAndExec: GodotPath
					arguments: aStringCollection
					environment: nil
					descriptors: nil
					workingDir: (self pivrPath / 'project') asString]]
]

{ #category : #deploy }
GRReact class >> stopAll [

	GRSocketListener stopAll.
	RunningGodotProcess ifNotNil: #terminate
]

{ #category : #testing }
GRReact class >> useFibers [

	^ true
]

{ #category : #reconciliation }
GRReact >> addChild: aNode in: aParentNode [

	aNode isGodotNode ifTrue: [self addUpdate: {#add. aParentNode godotPath}, (aNode createInfoFor: self)].
	^ super addChild: aNode in: aParentNode
]

{ #category : #reconciliation }
GRReact >> addRef: aRef for: aPathString [

	pendingRefs add: {aPathString. aRef}
]

{ #category : #reconciliation }
GRReact >> addUpdate: aTuple [

	pendingUpdates add: aTuple
]

{ #category : #reconciliation }
GRReact >> clearTree [

	self addUpdate: {#clear}.
	super clearTree
]

{ #category : #reconciliation }
GRReact >> deleteChildrenFrom: aNumber in: aParentNode [

	aParentNode childrenTreeNodes
		from: aNumber
		to: aParentNode childrenTreeNodes size
		do: [:node |
			node renderResultGodotPaths do: [:path | self addUpdate: {#delete. path}].
			node allEntriesDo: [:entry | (node ~= entry and: [entry node class = CMFReactNodePortal]) ifTrue: [entry renderResultGodotPaths do: [:path | self addUpdate: {#delete. path}]]]].
	^ super deleteChildrenFrom: aNumber in: aParentNode
]

{ #category : #'as yet unclassified' }
GRReact >> hostConfig [

	^ self
]

{ #category : #'initialize-release' }
GRReact >> initialize [

	super initialize.
	
	callbacks := GRCallbackRegistry new
]

{ #category : #reconciliation }
GRReact >> moveChild: aNode to: anotherNumber in: aParentNode [

	self addUpdate: {#move. aNode renderResultGodotPaths. anotherNumber}.
	super moveChild: aNode to: anotherNumber in: aParentNode
]

{ #category : #rendering }
GRReact >> performRenderChanges [

	false ifTrue: [
		Transcript showln: '------------'.
		pendingUpdates do: [:u | Transcript showln: u]].
	
	waitingRefs := pendingRefs collect: #second.
	changesBlock value: {pendingUpdates. pendingRefs collect: #first}.
	
	pendingUpdates removeAll.
	pendingRefs removeAll
]

{ #category : #rendering }
GRReact >> registerCallback: aClosure [

	^ callbacks registerCallback: aClosure
]

{ #category : #reconciliation }
GRReact >> replaceChildAt: aNumber with: aNode in: aParentNode [

	| oldChild |
	oldChild := aParentNode childrenTreeNodes at: aNumber.
	oldChild renderResultGodotPaths do: [:path | self addUpdate: {#delete. path}].
	oldChild allEntriesDo: [:entry | (oldChild ~= entry and: [entry node class = CMFReactNodePortal]) ifTrue: [entry renderResultGodotPaths do: [:path | self addUpdate: {#delete. path}]]].
	
	aNode isGodotNode ifTrue: [self addUpdate: {#add. aParentNode godotPath}, (aNode createInfoFor: self)].
	
	^ super replaceChildAt: aNumber with: aNode in: aParentNode
]

{ #category : #rendering }
GRReact >> replaceOldMorphsInWorld: old by: new isRoot: isRoot [

	isRoot ifTrue: [renderResult := new]
]

{ #category : #accessing }
GRReact >> session [

	^ session
]

{ #category : #accessing }
GRReact >> session: aSession [

	session := aSession
]

{ #category : #lifecycle }
GRReact >> subscribeToCodeChanges [
	"noop, conflict with our global listener"

	
]

{ #category : #rendering }
GRReact >> tick: aCollectionOfPendingCallbacks updatesDo: aBlock [

	changesBlock := aBlock.
	
	aCollectionOfPendingCallbacks
		ifNotEmpty: [
			GRReactCurrentSession
				value: session
				during: [aCollectionOfPendingCallbacks do: [:callback | (callbacks get: callback first) valueWithArguments: callback allButFirst]]]
		ifEmpty: ["if there were no pending callbacks, it's a full update request"
		self render]
]

{ #category : #lifecycle }
GRReact >> updateFrameDo: aBlock [

	| ret |
	pendingUpdates ifNil: [pendingUpdates := OrderedCollection new].
	pendingRefs ifNil: [pendingRefs := OrderedCollection new].
	GRReactCurrentSession value: session during: [ret := super updateFrameDo: aBlock].
	callbacks clean.
	^ ret
]

{ #category : #accessing }
GRReact >> waitingRefs [

	^ waitingRefs
]

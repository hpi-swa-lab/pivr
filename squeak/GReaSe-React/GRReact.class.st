Class {
	#name : #GRReact,
	#superclass : #CMFReact,
	#instVars : [
		'pendingUpdates',
		'callbacks',
		'server',
		'session',
		'pendingRefs',
		'waitingRefs'
	],
	#classVars : [
		'CurrentGodotId',
		'GodotPath',
		'RunningGodotProcess'
	],
	#category : #'GReaSe-React'
}

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

{ #category : #deploy }
GRReact class >> startGodot [

	(Smalltalk classNamed: #OSProcess) ifNotNil: [:shell |
		RunningGodotProcess ifNotNil: #terminate.
		GodotPath ifNil: [GodotPath := UIManager default request: 'Path to godot executable?'].
		RunningGodotProcess := shell isWindows
			ifTrue: [OSProcess command: ('{1} --path {2}' format: {GodotPath. (self pivrPath / 'project') asString})]
			ifFalse: [
				ExternalUnixOSProcess
					forkAndExec: GodotPath
					arguments: {}
					environment: nil
					descriptors: nil
					workingDir: (self pivrPath / 'project') asString]]
]

{ #category : #deploy }
GRReact class >> stopAll [

	GRSocketListener stopAll.
	RunningGodotProcess ifNotNil: #terminate
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
		do: [:node | node renderResultGodotPaths do: [:path | self addUpdate: {#delete. path}]].
	^ super deleteChildrenFrom: aNumber in: aParentNode
]

{ #category : #'initialize-release' }
GRReact >> initialize [

	super initialize.
	
	callbacks := GRCallbackRegistry new
]

{ #category : #reconciliation }
GRReact >> moveChild: aNode to: anotherNumber in: aParentNode [

	self addUpdate: {#move. aNode godotId}.
	super moveChild: aNode to: anotherNumber in: aParentNode
]

{ #category : #rendering }
GRReact >> registerCallback: aClosure [

	^ callbacks registerCallback: aClosure
]

{ #category : #reconciliation }
GRReact >> replaceChildAt: aNumber with: aNode in: aParentNode [

	(aParentNode childrenTreeNodes at: aNumber) renderResultGodotPaths do: [:path | self addUpdate: {#delete. path}].
	aNode isGodotNode ifTrue: [self addUpdate: {#add. aParentNode godotPath}, (aNode createInfoFor: self)].
	
	^ super replaceChildAt: aNumber with: aNode in: aParentNode
]

{ #category : #rendering }
GRReact >> replaceOldMorphsInWorld: old by: new isRoot: isRoot [

	isRoot ifTrue: [renderResult := new]
]

{ #category : #accessing }
GRReact >> session: aSession [

	session := aSession
]

{ #category : #'as yet unclassified' }
GRReact >> subscribeToCodeChanges [
	"noop, conflict with our global listener"

	
]

{ #category : #rendering }
GRReact >> tick: aCollectionOfPendingCallbacks [

	| return |
	aCollectionOfPendingCallbacks
		ifNotEmpty: [self batchUpdatesDuring: [aCollectionOfPendingCallbacks do: [:callback | (callbacks get: callback first) valueWithArguments: callback allButFirst]]]
		ifEmpty: ["if there were no pending callbacks, it's a full update request"
		self render].
	
	SBToggledCode comment: '' active: 0 do: {[pendingUpdates do: [:u | Transcript showln: u]]}.
	
	waitingRefs := pendingRefs collect: #second.
	return := {pendingUpdates. pendingRefs collect: #first}.
	pendingUpdates := nil.
	pendingRefs := nil.
	^ return
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

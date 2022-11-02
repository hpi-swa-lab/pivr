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
		'AutoStartApplications',
		'CurrentGodotId',
		'DebugCollisionShapes',
		'GodotPath',
		'InvertSimulatorCamera',
		'Port',
		'RunningGodotProcess',
		'UseSimulator'
	],
	#category : #'GReaSe-React'
}

{ #category : #deploy }
GRReact class >> current [

	^ GRSocketListener current
]

{ #category : #preferences }
GRReact class >> debugCollisionShapes [
	<preference: 'Debug Collision Shapes' category: 'GReaSe' description: 'Show outlines of collision shapes.' type: #Boolean>

	^ DebugCollisionShapes ifNil: [false]
]

{ #category : #preferences }
GRReact class >> debugCollisionShapes: aBoolean [

	DebugCollisionShapes := aBoolean
]

{ #category : #setup }
GRReact class >> findRepos [

	| base |
	base := FileDirectory default / '..' / '..' / '..'.
	{'pivr-tools'. 'pivr'} do: [:name | | folder workingCopy |
		folder := base / name.
		workingCopy := SquotWorkingCopy newOnObjectMemory
			name: name;
			repository: (SquitRepository new initializeInDirectory: (FileSystem disk root resolve: folder fullName));
			yourself.
		workingCopy repository unitOfWork activateDuring: [workingCopy loadedHistorian: workingCopy repository headHistorian].
		workingCopy register]
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

{ #category : #setup }
GRReact class >> pivrPath [

	^ self pivrRepo repository git workingDir
]

{ #category : #setup }
GRReact class >> pivrRepo [

	^ self repoOfName: 'pivr'
]

{ #category : #setup }
GRReact class >> pivrToolsRepo [

	^ self repoOfName: 'pivr-tools'
]

{ #category : #deploy }
GRReact class >> port [

	^ Port ifNil: [8292]
]

{ #category : #deploy }
GRReact class >> port: aNumber [

	Port := aNumber
]

{ #category : #deploy }
GRReact class >> questRestartApp [

	(Smalltalk classNamed: #OSProcess) ifNotNil: [:shell |
		shell waitForCommand: 'adb reverse tcp:8292 tcp:8292'.
		shell waitForCommand: 'adb shell am force-stop org.godotengine.grease'.
		shell waitForCommand: 'adb shell am start -n org.godotengine.grease/com.godot.game.GodotApp']
]

{ #category : #setup }
GRReact class >> repoOfName: aString [

	^ SquotWorkingCopy registered
		detect: [:each | | gitRepository |
			(each repository respondsTo: #git) and: [
				gitRepository := each repository git.
				each repository remoteNames anySatisfy: [:remote | (gitRepository remoteUrl: remote) matchesRegex: '.*/', aString, '($|\.).*']]]
		ifNone: [self error: 'repo missing?']
]

{ #category : #utils }
GRReact class >> resetGodotId [

	CurrentGodotId := 0
]

{ #category : #deploy }
GRReact class >> resetPort [

	Port := nil
]

{ #category : #deploy }
GRReact class >> startGodotWithArguments: aStringCollection [

	(Smalltalk classNamed: #OSProcess)
		ifNotNil: [:shell |
			RunningGodotProcess ifNotNil: [
				RunningGodotProcess class caseOf: {
					[ExternalUnixOSProcess] -> [RunningGodotProcess terminate].
					[ExternalWindowsOSProcess] -> [OSProcess command: ('taskkill.exe /PID {1} /f' format: {RunningGodotProcess pid})]}].
			GodotPath ifNil: [
				GodotPath := (FileDirectory default / '..' / '..' / '..' / 'godot' / (Smalltalk windowSystemName caseOf: {
					['Windows'] -> ['Godot_v3.5.1-stable_win64.exe'].
					['Win32'] -> ['Godot_v3.5.1-stable_win64.exe'].
					['Aqua'] -> ['Godot.app/Contents/MacOS/Godot'].
					['X11'] -> ['Godot_v3.5.1-stable_x11.64']})) fullName].
			(GodotPath isEmptyOrNil not and: [(shell isWindows and: [GodotPath first = $/]) or: [shell isWindows not and: [GodotPath first ~= $/]]]) ifTrue: [GodotPath := nil].
			(GodotPath isEmptyOrNil not and: [(FileDirectory directoryEntryFor: GodotPath) notNil]) ifFalse: [GodotPath := nil].
			GodotPath ifNil: [GodotPath := UIManager default request: 'Path to godot executable?'].
			RunningGodotProcess := shell isWindows
				ifTrue: [OSProcess command: ('{1} --path {2} {3}' format: {GodotPath. (self pivrPath / 'project') asString. aStringCollection joinSeparatedBy: ' '})]
				ifFalse: [
					ExternalUnixOSProcess
						forkAndExec: GodotPath
						arguments: aStringCollection
						environment: nil
						descriptors: nil
						workingDir: (self pivrPath / 'project') asString]]
		ifNil: [self error: 'starting godot requires OSProcess to be installed (or you can launch it externally)']
]

{ #category : #deploy }
GRReact class >> stopAll [

	GRSocketListener stopAll.
	RunningGodotProcess ifNotNil: [
		RunningGodotProcess class caseOf: {
			[ExternalUnixOSProcess] -> [RunningGodotProcess terminate].
			[ExternalWindowsOSProcess] -> [OSProcess command: ('taskkill.exe /PID {1} /f' format: {RunningGodotProcess pid})]}]
]

{ #category : #setup }
GRReact class >> update [

	Metacello new
		baseline: 'SBTreeSitter';
		onConflict: [:ex | ex allow];
		repository: 'github://hpi-swa-lab/sb-tree-sitter:master/packages';
		get;
		load.
	
	Metacello new
		baseline: 'CmfcmfReact';
		onConflict: [:ex | ex allow];
		repository: 'github://cmfcmf/ReactS:main/packages';
		get;
		load.
	
	(SquitInteractivePullFromUpstream workingCopy: self pivrToolsRepo) pull.
	(SquitInteractivePullFromUpstream workingCopy: self pivrRepo) pull
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

{ #category : #accessing }
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

{ #category : #'as yet unclassified' }
GRReact >> onShutdown [

	
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

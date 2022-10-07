Class {
	#name : #CMFHostConfigGodot,
	#superclass : #CMFHostConfig,
	#instVars : [
		'pendingUpdates',
		'callbacks',
		'session',
		'pendingRefs',
		'changesBlock',
		'waitingRefs'
	],
	#category : #'GReaSe-React'
}

{ #category : #'as yet unclassified' }
CMFHostConfigGodot >> addRef: aHostNode for: aPathString [

	pendingRefs add: {aPathString. aHostNode}
]

{ #category : #reconciliation }
CMFHostConfigGodot >> appendChild: aHostNode in: aParentHostNode [

	aHostNode at: 2 put: (aParentHostNode fourth asString
		ifNotEmpty: [aParentHostNode second, (aParentHostNode third ifTrue: [':'] ifFalse: ['/']), aParentHostNode fourth]
		ifEmpty: ['']).
	pendingUpdates add: aHostNode
]

{ #category : #reconciliation }
CMFHostConfigGodot >> create: aNode [

	^ {#add. nil}, (aNode createInfoFor: self)
]

{ #category : #reconciliation }
CMFHostConfigGodot >> diffPropsFrom: anOldNode to: aNewNode [

	^ anOldNode props
		ifNotNil: [:oldProps | | changes |
			changes := Dictionary new.
			aNewNode props
				ifNotNil: [:newProps |
					"which props have a new value or were added?"
					newProps keysAndValuesDo: [:key :value | (value isGodotNode not and: [((oldProps at: key ifAbsent: nil) grEqual: value) not]) ifTrue: [changes at: key put: value]].
					"did some properties disappear?"
					newProps size = oldProps size ifFalse: [oldProps keysDo: [:key | (newProps includesKey: key) ifFalse: [changes at: key put: nil]]]]
				ifNil: ["all removed"
				oldProps keysDo: [:key | changes at: key put: nil]].
			changes ifEmpty: [nil]]
		ifNil: ["all new"
		aNewNode props ifNotNil: [:p | p copy ifEmpty: nil]]
]

{ #category : #reconciliation }
CMFHostConfigGodot >> fullPathFor: aNode [

	^ aNode fourth asString
		ifNotEmpty: [aNode second, (aNode third ifTrue: [':'] ifFalse: ['/']), aNode fourth]
		ifEmpty: ['']
]

{ #category : #'initialize-release' }
CMFHostConfigGodot >> initialize [

	super initialize.
	
	callbacks := GRCallbackRegistry new.
	
	pendingUpdates := OrderedCollection new.
	pendingRefs := OrderedCollection new
]

{ #category : #reconciliation }
CMFHostConfigGodot >> insert: aHostNode before: aSiblingHostNode in: aParentHostNode [

	| node |
	node := aHostNode.
	node at: 2 put: (self fullPathFor: aParentHostNode).
	aHostNode at: 1 put: #insert.
	aHostNode at: 7 put: (self fullPathFor: aSiblingHostNode).
	
	pendingUpdates add: node
]

{ #category : #reconciliation }
CMFHostConfigGodot >> prepareUpdateFrom: aNode to: anotherNode for: aHostNode [

	^ self diffPropsFrom: aNode to: anotherNode
]

{ #category : #'as yet unclassified' }
CMFHostConfigGodot >> registerCallback: aClosure [

	^ callbacks registerCallback: aClosure
]

{ #category : #reconciliation }
CMFHostConfigGodot >> removeChild: aHostNode in: aParentHostNode [

	pendingUpdates add: {#delete. self fullPathFor: aHostNode. aHostNode fifth}
]

{ #category : #reconciliation }
CMFHostConfigGodot >> resetAfterCommit [

	changesBlock ifNil: [^ self].
	
	false ifTrue: [
		Transcript showln: '------------'.
		pendingUpdates do: [:u | Transcript showln: u]].
	
	waitingRefs := pendingRefs collect: #second.
	changesBlock value: {pendingUpdates. pendingRefs collect: [:ref | self fullPathFor: ref first]}.
	pendingUpdates removeAll.
	pendingRefs removeAll
]

{ #category : #'as yet unclassified' }
CMFHostConfigGodot >> session [

	^ session
]

{ #category : #'as yet unclassified' }
CMFHostConfigGodot >> session: aSession [

	session := aSession
]

{ #category : #'as yet unclassified' }
CMFHostConfigGodot >> tick: aCollectionOfPendingCallbacks updatesDo: aBlock [

	changesBlock := aBlock.
	aCollectionOfPendingCallbacks
		ifNotEmpty: [
			GRReactCurrentSession
				value: session
				during: [self updateFrameDo: [aCollectionOfPendingCallbacks do: [:callback | (callbacks get: callback first) valueWithArguments: callback allButFirst]]]]
		ifEmpty: ["if there were no pending callbacks, it's a full update request"
		react reRenderAll]
]

{ #category : #reconciliation }
CMFHostConfigGodot >> update: aHostNode new: aNewNode hostUpdate: aHostUpdate [

	aHostUpdate keysAndValuesDo: [:key :value |
		pendingUpdates add: {
			#update.
			aHostNode second, (aHostNode third ifTrue: [':'] ifFalse: ['/']), aHostNode fourth.
			key.
			aNewNode serializePropValue: value for: react hostConfig}]
]

{ #category : #reconciliation }
CMFHostConfigGodot >> updateFrameDo: aBlock [

	^ GRReactCurrentSession value: session during: [super updateFrameDo: aBlock]
]

{ #category : #'as yet unclassified' }
CMFHostConfigGodot >> waitingRefs [

	^ waitingRefs
]

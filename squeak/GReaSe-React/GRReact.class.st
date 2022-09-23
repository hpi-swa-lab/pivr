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
		'CurrentGodotId'
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

{ #category : #reconciliation }
GRReact >> addChild: aNode in: aParentNode [

	aNode isGodotNode ifTrue: [self addUpdate: {#add. aParentNode godotPath}, aNode createInfo].
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
GRReact >> deleteChildrenFrom: aNumber in: aParentNode [

	aParentNode childrenTreeNodes
		from: aNumber
		to: aParentNode childrenTreeNodes size
		do: [:node | self addUpdate: {#delete. node godotPath}].
	^ super deleteChildrenFrom: aNumber in: aParentNode
]

{ #category : #'initialize-release' }
GRReact >> initialize [

	super initialize.
	
	callbacks := Dictionary new
]

{ #category : #reconciliation }
GRReact >> moveChild: aNode to: anotherNumber in: aParentNode [

	self addUpdate: {#move. aNode godotId}.
	super moveChild: aNode to: anotherNumber in: aParentNode
]

{ #category : #rendering }
GRReact >> registerCallback: aClosure [

	| id |
	callbacks keysAndValuesDo: [:closureId :closure | closure == aClosure ifTrue: [^ closureId]].
	
	id := self class nextGodotId.
	callbacks at: id put: aClosure.
	^ id
]

{ #category : #reconciliation }
GRReact >> replaceChildAt: aNumber with: aNode in: aParentNode [

	self addUpdate: {#replace. (aParentNode childrenTreeNodes at: aNumber) godotPath}, aNode createInfo.
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

{ #category : #rendering }
GRReact >> tick: aCollectionOfPendingCallbacks [

	| currentPending allUpdates currentPendingRefs allPendingRefs |
	currentPending := (pendingUpdates ifNil: [#()]) copy.
	pendingUpdates := OrderedCollection new.
	currentPendingRefs := (pendingRefs ifNil: [#()]) copy.
	pendingRefs := OrderedCollection new.
	
	aCollectionOfPendingCallbacks
		ifNotEmpty: [self batchUpdatesDuring: [aCollectionOfPendingCallbacks do: [:callback | (callbacks at: callback first) valueWithArguments: callback allButFirst]]]
		ifEmpty: ["if there were no pending callbacks, it's a full update request"
		self render].
	
	allUpdates := currentPending, pendingUpdates.
	SBToggledCode comment: '' active: 0 do: {[allUpdates do: [:u | Transcript showln: u]]}.
	allPendingRefs := currentPendingRefs, pendingRefs.
	pendingUpdates := nil.
	pendingRefs := nil.
	waitingRefs := allPendingRefs collect: #second.
	^ {allUpdates. allPendingRefs collect: #first}
]

{ #category : #lifecycle }
GRReact >> updateFrameDo: aBlock [

	| ret |
	pendingUpdates := OrderedCollection new.
	pendingRefs := OrderedCollection new.
	GRReactCurrentSession value: session during: [ret := super updateFrameDo: aBlock].
	^ ret
]

{ #category : #accessing }
GRReact >> waitingRefs [

	^ waitingRefs
]

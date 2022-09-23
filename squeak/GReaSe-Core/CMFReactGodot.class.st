Class {
	#name : #CMFReactGodot,
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
	#category : #'GReaSe-Core'
}

{ #category : #testing }
CMFReactGodot class >> isValidRenderResult: anObject [

	^ anObject isGodotNode or: [anObject isSequenceable and: [anObject allSatisfy: [:o | o isGodotNode]]]
]

{ #category : #utils }
CMFReactGodot class >> nextGodotId [

	CurrentGodotId ifNil: [CurrentGodotId := 0].
	CurrentGodotId := CurrentGodotId + 1.
	CurrentGodotId > 900000000 ifTrue: [CurrentGodotId := 0].
	^ CurrentGodotId
]

{ #category : #reconciliation }
CMFReactGodot >> addChild: aNode in: aParentNode [

	aNode isGodotNode ifTrue: [self addUpdate: {#add. aParentNode godotPath}, aNode createInfo].
	^ super addChild: aNode in: aParentNode
]

{ #category : #reconciliation }
CMFReactGodot >> addRef: aRef for: aPathString [

	pendingRefs add: {aPathString. aRef}
]

{ #category : #reconciliation }
CMFReactGodot >> addUpdate: aTuple [

	pendingUpdates add: aTuple
]

{ #category : #reconciliation }
CMFReactGodot >> deleteChildrenFrom: aNumber in: aParentNode [

	aParentNode childrenTreeNodes
		from: aNumber
		to: aParentNode childrenTreeNodes size
		do: [:node | self addUpdate: {#delete. node godotPath}].
	^ super deleteChildrenFrom: aNumber in: aParentNode
]

{ #category : #'initialize-release' }
CMFReactGodot >> initialize [

	super initialize.
	
	callbacks := Dictionary new
]

{ #category : #reconciliation }
CMFReactGodot >> moveChild: aNode to: anotherNumber in: aParentNode [

	self addUpdate: {#move. aNode godotId}.
	super moveChild: aNode to: anotherNumber in: aParentNode
]

{ #category : #rendering }
CMFReactGodot >> registerCallback: aClosure [

	| id |
	callbacks keysAndValuesDo: [:closureId :closure | closure == aClosure ifTrue: [^ closureId]].
	
	id := self class nextGodotId.
	callbacks at: id put: aClosure.
	^ id
]

{ #category : #reconciliation }
CMFReactGodot >> replaceChildAt: aNumber with: aNode in: aParentNode [

	self addUpdate: {#replace. (aParentNode childrenTreeNodes at: aNumber) godotPath}, aNode createInfo.
	^ super replaceChildAt: aNumber with: aNode in: aParentNode
]

{ #category : #rendering }
CMFReactGodot >> replaceOldMorphsInWorld: old by: new isRoot: isRoot [

	isRoot ifTrue: [renderResult := new]
]

{ #category : #accessing }
CMFReactGodot >> session: aSession [

	session := aSession
]

{ #category : #rendering }
CMFReactGodot >> tick: aCollectionOfPendingCallbacks [

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
CMFReactGodot >> updateFrameDo: aBlock [

	| ret |
	pendingUpdates := OrderedCollection new.
	pendingRefs := OrderedCollection new.
	GDCurrentSession value: session during: [ret := super updateFrameDo: aBlock].
	^ ret
]

{ #category : #accessing }
CMFReactGodot >> waitingRefs [

	^ waitingRefs
]

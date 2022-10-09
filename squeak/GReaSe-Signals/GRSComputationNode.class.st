Class {
	#name : #GRSComputationNode,
	#superclass : #Object,
	#instVars : [
		'age',
		'state',
		'sources',
		'sourceSlots',
		'log',
		'value',
		'owned',
		'cleanup',
		'computation'
	],
	#category : #'GReaSe-Signals'
}

{ #category : #'as yet unclassified' }
GRSComputationNode class >> finishToplevel [

	(GRSEffect rootClock changes notEmpty or: [GRSEffect rootClock updates notEmpty]) ifTrue: [
		GRSEffect rootClock incrementTime.
		[GRSEffect rootClock run] ensure: [GRSEffect runningClock: nil]]
]

{ #category : #'as yet unclassified' }
GRSComputationNode class >> newDo: aBlock value: anObject orphan: anOrphanBoolean sample: aSampleBoolean [

	| isToplevel node value wasRecycled |
	node := self new.
	isToplevel := GRSEffect runningClock isNil.
	value := GRSEffect listener: (aSampleBoolean ifTrue: [nil] ifFalse: [node]) during: [
		GRSEffect
			owner: node
			during: [isToplevel ifTrue: [self runToplevel: aBlock with: anObject] ifFalse: [aBlock cull: anObject]]].
	wasRecycled := self recycleOrClaim: node do: aBlock value: value orphan: anOrphanBoolean.
	isToplevel ifTrue: [self finishToplevel].
	self assert: GRSEffect runningClock isNil.
	^ {wasRecycled ifTrue: [nil] ifFalse: [node]. value}
]

{ #category : #'as yet unclassified' }
GRSComputationNode class >> recycleOrClaim: aNode do: aBlock value: anObject orphan: anOrphanBoolean [

	| owner recycle |
	owner := (anOrphanBoolean or: [GRSEffect owner isNil or: [GRSEffect owner == #grUnowned]])
		ifTrue: [nil]
		ifFalse: [GRSEffect owner].
	recycle := aNode sources isEmpty and: [(aNode hasOwned and: [aNode hasCleanup]) or: [owner notNil]].
	
	recycle
		ifTrue: [
			owner ifNotNil: [
				owner addOwned: aNode owned.
				owner addCleanup: aNode cleanup]]
		ifFalse: [
			aNode
				computation: aBlock;
				value: anObject;
				age: GRSEffect rootClock time.
			owner ifNotNil: [owner addOwned: {aNode}]].
	
	^ recycle
]

{ #category : #'as yet unclassified' }
GRSComputationNode class >> runToplevel: aBlock with: anObject [

	GRSEffect runningClock: GRSEffect rootClock.
	GRSEffect rootClock changes removeAll.
	GRSEffect rootClock updates removeAll.
	^ [aBlock cull: anObject] ensure: [GRSEffect runningClock: nil]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> addCleanup: aCollectionOrNil [

	aCollectionOrNil ifNotNil: [
		cleanup ifNil: [cleanup := OrderedCollection new].
		cleanup addAll: aCollectionOrNil]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> addOwned: aCollectionOrNil [

	aCollectionOrNil ifNotNil: [
		owned ifNil: [owned := OrderedCollection new].
		owned addAll: aCollectionOrNil]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> age: aNumber [

	age := aNumber
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> cleanup: aFinalBoolean [

	self cleanupDo: [:block | block value: aFinalBoolean].
	cleanup := nil.
	
	self ownedDo: [:node | node dispose].
	owned := nil.
	
	sources do: [:log | log cleanupSource: self].
	sources removeAll
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> cleanupDo: aBlock [

	cleanup ifNotNil: [cleanup do: aBlock]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> computation: aBlock [

	computation := aBlock
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> dispose [

	computation := nil.
	log := nil.
	self cleanup: true
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> hasCleanup [

	^ cleanup notNil and: [cleanup notEmpty]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> hasOwned [

	^ owned notNil and: [owned notEmpty]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> initialize [

	age := -1.
	state := #current.
	sources := OrderedCollection new.
	sourceSlots := OrderedCollection new
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> log [

	^ log ifNil: [log := GRSLog new]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> markForDisposal [

	age := GRSEffect rootClock time.
	state := #current.
	self ownedDo: [:node | node markForDisposal]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> markStale [

	| time |
	time := GRSEffect rootClock time.
	age < time ifTrue: [
		age := time.
		state := #stale.
		GRSEffect rootClock addUpdate: self.
		self ownedDo: [:node | node markForDisposal]]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> owned [

	^ owned
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> owned: aNode [

	owned := aNode
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> ownedDo: aBlock [

	owned ifNotNil: [owned do: aBlock]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> sources [

	^ sources
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> update [

	state = #stale ifTrue: [
		GRSEffect owner: self during: [
			GRSEffect listener: self during: [
				state := #running.
				self cleanup: false.
				value := computation cull: value.
				state := #current]]]
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> value [

	GRSEffect listener ifNotNil: [
		age = GRSEffect rootClock time ifTrue: [
			state = #running ifTrue: [self error: 'circular dependency'] ifFalse: [self update].
			self log read]].
	^ value
]

{ #category : #'as yet unclassified' }
GRSComputationNode >> value: anObject [

	value := anObject
]

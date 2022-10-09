Class {
	#name : #GRSEffect,
	#superclass : #Object,
	#classVars : [
		'Listener',
		'Owner',
		'RootClock',
		'RunningClock'
	],
	#category : #'GReaSe-Signals'
}

{ #category : #'as yet unclassified' }
GRSEffect class >> do: aBlock [

	| nodeAndValue value node |
	nodeAndValue := GRSComputationNode newDo: aBlock value: nil orphan: false sample: false.
	node := nodeAndValue first.
	value := nodeAndValue second.
	^ node ifNil: [[value]] ifNotNil: [[node value]]
]

{ #category : #'as yet unclassified' }
GRSEffect class >> isFrozen [

	^ RunningClock notNil
]

{ #category : #'as yet unclassified' }
GRSEffect class >> isListening [

	^ Listener notNil
]

{ #category : #'as yet unclassified' }
GRSEffect class >> listener [

	^ Listener
]

{ #category : #'as yet unclassified' }
GRSEffect class >> listener: aNode during: aBlock [

	| previous |
	previous := Listener.
	Listener := aNode.
	^ aBlock ensure: [Listener := previous]
]

{ #category : #'as yet unclassified' }
GRSEffect class >> noteEvent [

	| owner |
	owner := Owner.
	self rootClock updates removeAll.
	self rootClock incrementTime.
	[self rootClock run] ensure: [
		RunningClock := nil.
		Listener := nil.
		Owner := owner]
]

{ #category : #'as yet unclassified' }
GRSEffect class >> owner [

	^ Owner
]

{ #category : #'as yet unclassified' }
GRSEffect class >> owner: aNode during: aBlock [

	| previous |
	previous := Owner.
	Owner := aNode.
	^ aBlock ensure: [Owner := previous]
]

{ #category : #'as yet unclassified' }
GRSEffect class >> reset [

	RootClock := nil.
	RunningClock := nil
]

{ #category : #'as yet unclassified' }
GRSEffect class >> rootClock [

	^ RootClock ifNil: [RootClock := GRSClock new]
]

{ #category : #'as yet unclassified' }
GRSEffect class >> runningClock [

	^ RunningClock
]

{ #category : #'as yet unclassified' }
GRSEffect class >> runningClock: aClock [

	RunningClock := aClock
]

{ #category : #'as yet unclassified' }
GRSEffect class >> sampleDuring: aBlock [

	| previous |
	previous := Listener.
	Listener := nil.
	^ [aBlock value] ensure: [Listener := previous]
]

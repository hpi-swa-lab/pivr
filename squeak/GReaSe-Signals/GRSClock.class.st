Class {
	#name : #GRSClock,
	#superclass : #Object,
	#instVars : [
		'time',
		'changes',
		'updates',
		'disposes'
	],
	#category : #'GReaSe-Signals'
}

{ #category : #'as yet unclassified' }
GRSClock >> addChange: aNode [

	changes ifNil: [changes := OrderedCollection new].
	changes add: aNode
]

{ #category : #'as yet unclassified' }
GRSClock >> addUpdate: aNode [

	updates ifNil: [updates := OrderedCollection new].
	updates add: aNode
]

{ #category : #'as yet unclassified' }
GRSClock >> changes [

	^ changes
]

{ #category : #'as yet unclassified' }
GRSClock >> disposes [

	^ disposes
]

{ #category : #'as yet unclassified' }
GRSClock >> incrementTime [

	time := time + 1
]

{ #category : #'as yet unclassified' }
GRSClock >> initialize [

	time := 0.
	changes := OrderedCollection new.
	updates := OrderedCollection new.
	disposes := OrderedCollection new
]

{ #category : #'as yet unclassified' }
GRSClock >> run [

	| running count |
	running := GRSEffect runningClock.
	count := 0.
	disposes removeAll.
	
	[changes notEmpty or: [updates notEmpty or: [disposes notEmpty]]] whileTrue: [
		count > 0 ifTrue: [self incrementTime].
		changes do: [:node | node applyDataChange]; removeAll.
		updates do: [:node | node update]; removeAll.
		disposes do: [:node | node dispose]; removeAll.
		count := count + 1.
		count > 100000 ifTrue: [self error: 'Potential runaway clock']].
	
	GRSEffect runningClock: running
]

{ #category : #'as yet unclassified' }
GRSClock >> time [

	^ time
]

{ #category : #'as yet unclassified' }
GRSClock >> updates [

	^ updates
]

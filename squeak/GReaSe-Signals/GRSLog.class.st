Class {
	#name : #GRSLog,
	#superclass : #Object,
	#instVars : [
		'nodes',
		'nodeSlots'
	],
	#category : #'GReaSe-Signals'
}

{ #category : #'as yet unclassified' }
GRSLog >> cleanupSource: aNode [

	nodes remove: aNode
]

{ #category : #'as yet unclassified' }
GRSLog >> initialize [

	nodes := OrderedCollection new.
	nodeSlots := OrderedCollection new
]

{ #category : #'as yet unclassified' }
GRSLog >> markComputationsStale [

	nodes do: [:node | node markStale]
]

{ #category : #'as yet unclassified' }
GRSLog >> nodes [

	^ nodes
]

{ #category : #'as yet unclassified' }
GRSLog >> read [

	| from to |
	from := self.
	to := GRSEffect listener.
	
	from nodes add: to.
	to sources add: from
]

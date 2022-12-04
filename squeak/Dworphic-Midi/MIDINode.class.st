Class {
	#name : #MIDINode,
	#superclass : #Object,
	#instVars : [
		'children',
		'parent'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDINode >> addChild: aNode [

	aNode parent ifNotNil: [:p | p removeChild: aNode].
	children add: aNode.
	aNode parent: self
]

{ #category : #'as yet unclassified' }
MIDINode >> addedToPlayer: aPlayer [

	
]

{ #category : #'as yet unclassified' }
MIDINode >> allChildrenDo: aBlock [

	self children do: [:c | c allChildrenDo: aBlock].
	aBlock value: self
]

{ #category : #'as yet unclassified' }
MIDINode >> children [

	^ children
]

{ #category : #'as yet unclassified' }
MIDINode >> initialize [

	super initialize.
	
	children := OrderedCollection new
]

{ #category : #'as yet unclassified' }
MIDINode >> parent [

	^ parent
]

{ #category : #'as yet unclassified' }
MIDINode >> parent: aNode [

	parent := aNode
]

{ #category : #'as yet unclassified' }
MIDINode >> player [

	^ self parent ifNotNil: #player
]

{ #category : #'as yet unclassified' }
MIDINode >> removeChild: aChild [

	children remove: aChild.
	self player ifNotNil: [:p | aChild allChildrenDo: [:c | c removedFromPlayer: p]]
]

{ #category : #'as yet unclassified' }
MIDINode >> removedFromPlayer: aPlayer [

	
]

{ #category : #'as yet unclassified' }
MIDINode >> step [

	
]

{ #category : #'as yet unclassified' }
MIDINode >> stepDownBeat: aTimeInMilliseconds delta: aNumberInMilliseconds [

	
]

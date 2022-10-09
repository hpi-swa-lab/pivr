Class {
	#name : #GRSDataNode,
	#superclass : #Object,
	#instVars : [
		'pending',
		'log',
		'value'
	],
	#category : #'GReaSe-Signals'
}

{ #category : #'as yet unclassified' }
GRSDataNode class >> with: anObject [

	^ self new initValue: anObject
]

{ #category : #'as yet unclassified' }
GRSDataNode >> applyDataChange [

	value := pending.
	pending := #grNotPending.
	log ifNotNil: [log markComputationsStale]
]

{ #category : #'as yet unclassified' }
GRSDataNode >> get [

	^ self value
]

{ #category : #'as yet unclassified' }
GRSDataNode >> initValue: anObject [

	value := anObject
]

{ #category : #'as yet unclassified' }
GRSDataNode >> initialize [

	pending := #grNotPending.
	log := nil
]

{ #category : #'as yet unclassified' }
GRSDataNode >> log [

	^ log ifNil: [log := GRSLog new]
]

{ #category : #'as yet unclassified' }
GRSDataNode >> set: anObject [

	self value: anObject
]

{ #category : #'as yet unclassified' }
GRSDataNode >> value [

	GRSEffect listener ifNotNil: [self log read].
	^ value
]

{ #category : #'as yet unclassified' }
GRSDataNode >> value: anObject [

	| val |
	val := anObject isBlock ifTrue: [anObject value: value] ifFalse: [anObject].
	GRSEffect runningClock
		ifNotNil: [
			pending == #grNotPending
				ifFalse: [val = pending ifFalse: [self error: 'conflicting changes']]
				ifTrue: [
					pending := val.
					GRSEffect rootClock addChange: self]]
		ifNil: [
			log
				ifNotNil: [
					pending := val.
					GRSEffect rootClock addChange: self.
					GRSEffect noteEvent]
				ifNil: [pending := val]].
	^ val
]

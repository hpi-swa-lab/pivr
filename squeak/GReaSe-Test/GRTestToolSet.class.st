Class {
	#name : #GRTestToolSet,
	#superclass : #StandardToolSet,
	#category : #'GReaSe-Test'
}

{ #category : #'as yet unclassified' }
GRTestToolSet class >> activeDuring: aBlock [

	| originalToolset |
	originalToolset := ToolSet default.
	ToolSet default: self new.
	aBlock ensure: [ToolSet default: originalToolset]
]

{ #category : #'as yet unclassified' }
GRTestToolSet class >> debugException: anException [

	anException signal
]

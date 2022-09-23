Class {
	#name : #GRBlockWithArguments,
	#superclass : #Object,
	#instVars : [
		'block',
		'arguments'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRBlockWithArguments >> = anotherBlock [

	^ self block = anotherBlock block and: [self arguments = anotherBlock arguments]
]

{ #category : #'as yet unclassified' }
GRBlockWithArguments >> arguments [

	^ arguments
]

{ #category : #'as yet unclassified' }
GRBlockWithArguments >> block [

	^ block
]

{ #category : #'as yet unclassified' }
GRBlockWithArguments >> block: aBlock arguments: aCollection [

	block := aBlock.
	arguments := aCollection
]

{ #category : #'as yet unclassified' }
GRBlockWithArguments >> valueWithArguments: aSequenceOfArguments [

	^ block valueWithArguments: aSequenceOfArguments
]

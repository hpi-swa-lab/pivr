Class {
	#name : #GRBlockReplace,
	#superclass : #Object,
	#instVars : [
		'id',
		'block'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRBlockReplace >> block [

	^ block
]

{ #category : #'as yet unclassified' }
GRBlockReplace >> id [

	^ id
]

{ #category : #'as yet unclassified' }
GRBlockReplace >> id: aNumber block: aBlock [

	id := aNumber.
	block := aBlock
]

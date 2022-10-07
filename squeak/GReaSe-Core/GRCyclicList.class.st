Class {
	#name : #GRCyclicList,
	#superclass : #Object,
	#instVars : [
		'array',
		'cursor'
	],
	#category : #'GReaSe-Core-Debug'
}

{ #category : #'as yet unclassified' }
GRCyclicList >> add: aNumber [

	array at: cursor put: aNumber.
	cursor := cursor + 1.
	cursor > array size ifTrue: [cursor := 1]
]

{ #category : #'as yet unclassified' }
GRCyclicList >> contents [

	^ Array streamContents: [:stream | self do: [:value | stream nextPut: value]]
]

{ #category : #'as yet unclassified' }
GRCyclicList >> do: aBlock [

	array from: cursor to: array size do: aBlock.
	array from: 1 to: cursor - 1 do: aBlock
]

{ #category : #'as yet unclassified' }
GRCyclicList >> initialize [

	super initialize.
	array := {0}.
	self size: 1
]

{ #category : #'as yet unclassified' }
GRCyclicList >> last [

	^ array at: (cursor = 1 ifTrue: [array size] ifFalse: [cursor - 1])
]

{ #category : #'as yet unclassified' }
GRCyclicList >> max [

	^ array max
]

{ #category : #'as yet unclassified' }
GRCyclicList >> reverseDo: aBlock [

	self contents reverseDo: aBlock
]

{ #category : #'as yet unclassified' }
GRCyclicList >> reverseWithIndexDo: aBlock [

	| index |
	index := 1.
	self reverseDo: [:value |
		aBlock value: value value: index.
		index := index + 1]
]

{ #category : #'as yet unclassified' }
GRCyclicList >> size [

	^ array size
]

{ #category : #'as yet unclassified' }
GRCyclicList >> size: aNumber [

	| newArray |
	newArray := Array new: aNumber withAll: 0.
	newArray
		replaceFrom: (aNumber - array size + 1 max: 1)
		to: newArray size
		with: array
		startingAt: (array size - aNumber + 1 max: 1).
	array := newArray.
	cursor := array size - 1
]

{ #category : #'as yet unclassified' }
GRCyclicList >> withIndexDo: aBlock [

	| index |
	index := 1.
	self do: [:value |
		aBlock value: value value: index.
		index := index + 1]
]

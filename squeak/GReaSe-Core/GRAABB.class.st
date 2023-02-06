Class {
	#name : #GRAABB,
	#superclass : #Object,
	#instVars : [
		'position',
		'size'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRAABB class >> position: a size: b [

	^ self new position: a; size: b
]

{ #category : #'as yet unclassified' }
GRAABB class >> position: a size: b end: c [

	^ self new position: a; size: b; end: c
]

{ #category : #'as yet unclassified' }
GRAABB >> * aNumber [

	^ self copy
		position: self position * aNumber;
		size: self size * aNumber;
		yourself
]

{ #category : #'as yet unclassified' }
GRAABB >> extents [

	^ size / 2.0
]

{ #category : #'as yet unclassified' }
GRAABB >> position [

	^ position
]

{ #category : #'as yet unclassified' }
GRAABB >> position: aVector [

	position := aVector
]

{ #category : #'as yet unclassified' }
GRAABB >> size [

	^ size
]

{ #category : #'as yet unclassified' }
GRAABB >> size: aVector [

	size := aVector
]

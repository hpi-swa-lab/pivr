Class {
	#name : #GRNodePath,
	#superclass : #Object,
	#instVars : [
		'path'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRNodePath class >> path: aString [

	^ self new path: aString
]

{ #category : #'as yet unclassified' }
GRNodePath >> path: aString [

	path := aString
]

{ #category : #'as yet unclassified' }
GRNodePath >> putVariantOn: aStream [

	| names subnameCount isAbsolute |
	names := (path splitBy: '/') select: #notEmpty.
	isAbsolute := path first = $/.
	self flag: #todo.
	subnameCount := 0.
	aStream nextLittleEndianNumber: 4 put: 15.
	aStream nextLittleEndianNumber: 4 put: (names size bitOr: 66571993088).
	aStream nextLittleEndianNumber: 4 put: subnameCount.
	aStream nextLittleEndianNumber: 4 put: (isAbsolute ifTrue: [1] ifFalse: [0]).
	names do: [:name | name putVariantOn: aStream skipType: true]
]

Class {
	#name : #GRPoolVector2Array,
	#superclass : #OrderedCollection,
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRPoolVector2Array >> at: anInteger put: anObject [

	self assert: anObject isVector2.
	^ super at: anInteger put: anObject
]

{ #category : #'as yet unclassified' }
GRPoolVector2Array >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 24.
	aStream nextLittleEndianNumber: 4 put: self size.
	self do: [:vector |
		aStream nextLittleEndianNumber: 4 put: vector x asIEEE32BitWord.
		aStream nextLittleEndianNumber: 4 put: vector y asIEEE32BitWord]
]

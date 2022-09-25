Extension { #name : #Vector3 }

{ #category : #'*GReaSe-Core' }
Vector3 >> closeTo: aVector3 [

	^ (self x closeTo: aVector3 x) and: [(self y closeTo: aVector3 y) and: [self z closeTo: aVector3 z]]
]

{ #category : #'*GReaSe-Core' }
Vector3 >> grEqual: anObject [

	^ self = anObject
]

{ #category : #'*GReaSe-Core' }
Vector3 >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 7.
	aStream nextLittleEndianNumber: 4 put: self x asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self y asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self z asIEEE32BitWord
]

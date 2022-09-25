Extension { #name : #Point }

{ #category : #'*GReaSe-Core' }
Point >> grEqual: anObject [

	^ self = anObject
]

{ #category : #'*GReaSe-Core' }
Point >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 5.
	aStream nextLittleEndianNumber: 4 put: self x asFloat asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self y asFloat asIEEE32BitWord
]

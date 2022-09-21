Extension { #name : #Vector3 }

{ #category : #'*GReaSe-Core' }
Vector3 >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 7.
	aStream nextLittleEndianNumber: 4 put: self x asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self y asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self z asIEEE32BitWord
]

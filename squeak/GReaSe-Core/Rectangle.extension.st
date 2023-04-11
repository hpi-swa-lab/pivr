Extension { #name : #Rectangle }

{ #category : #'*GReaSe-Core' }
Rectangle >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 6.
	aStream nextLittleEndianNumber: 4 put: self left asFloat asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self top asFloat asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self width asFloat asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self height asFloat asIEEE32BitWord
]

Extension { #name : #Color }

{ #category : #'*GReaSe-Core' }
Color >> grEqual: anObject [

	^ self = anObject
]

{ #category : #'*GReaSe-Core' }
Color >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 14.
	aStream nextLittleEndianNumber: 4 put: self red asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self green asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self blue asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self alpha asIEEE32BitWord
]

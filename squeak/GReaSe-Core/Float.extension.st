Extension { #name : #Float }

{ #category : #'*GReaSe-Core' }
Float >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: (3 bitOr: (1 bitShift: 16)).
	aStream nextLittleEndianNumber: 8 put: self asIEEE64BitWord
]

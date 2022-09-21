Extension { #name : #Integer }

{ #category : #'*GReaSe-Core' }
Integer >> putVariantOn: aStream [
	"64bit? negative numbers?"

	self flag: #todo.
	aStream nextLittleEndianNumber: 4 put: 2.
	aStream nextLittleEndianNumber: 4 put: self
]

Extension { #name : #UndefinedObject }

{ #category : #'*GReaSe-Core' }
UndefinedObject >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 0
]

Extension { #name : #Boolean }

{ #category : #'*GReaSe-Core' }
Boolean >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 1.
	aStream nextLittleEndianNumber: 4 put: (self ifTrue: [1] ifFalse: [0])
]

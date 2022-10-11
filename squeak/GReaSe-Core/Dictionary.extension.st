Extension { #name : #Dictionary }

{ #category : #'*GReaSe-Core' }
Dictionary >> copyWithoutKey: aKey [

	^ self copy removeKey: aKey; yourself
]

{ #category : #'*GReaSe-Core' }
Dictionary >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 18.
	aStream nextLittleEndianNumber: 4 put: self size.
	self keysAndValuesDo: [:key :value |
		key putVariantOn: aStream.
		value putVariantOn: aStream]
]

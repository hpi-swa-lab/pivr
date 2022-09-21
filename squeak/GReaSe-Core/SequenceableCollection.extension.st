Extension { #name : #SequenceableCollection }

{ #category : #'*GReaSe-Core' }
SequenceableCollection >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 19.
	aStream nextLittleEndianNumber: 4 put: self size.
	self do: [:element | element putVariantOn: aStream]
]

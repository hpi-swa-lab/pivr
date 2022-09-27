Extension { #name : #Bitmap }

{ #category : #'*GReaSe-Core' }
Bitmap >> putVariantOn: aStream [
	"pool_byte_array"

	aStream nextLittleEndianNumber: 4 put: 20.
	aStream nextLittleEndianNumber: 4 put: self size * 4.
	1 to: self size do: [:index | aStream nextLittleEndianNumber: 4 put: (self at: index)]
]

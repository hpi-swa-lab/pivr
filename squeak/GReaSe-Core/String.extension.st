Extension { #name : #String }

{ #category : #'*GReaSe-Core' }
String >> putVariantOn: aStream [

	| buffer |
	aStream nextLittleEndianNumber: 4 put: 4.
	buffer := self utf8Encoded.
	aStream nextLittleEndianNumber: 4 put: buffer size.
	aStream nextPutAll: buffer.
	buffer size \\ 4 ~= 0 ifTrue: [4 - (buffer size \\ 4) timesRepeat: [aStream nextPut: 0]]
]

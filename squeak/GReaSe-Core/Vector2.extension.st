Extension { #name : #Vector2 }

{ #category : #'*GReaSe-Core' }
Vector2 >> grEqual: anObject [

	^ self = anObject
]

{ #category : #'*GReaSe-Core' }
Vector2 >> isVector2 [

	^ true
]

{ #category : #'*GReaSe-Core' }
Vector2 >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 5.
	aStream nextLittleEndianNumber: 4 put: self x asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self y asIEEE32BitWord
]

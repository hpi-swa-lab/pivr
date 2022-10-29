Extension { #name : #Collection }

{ #category : #'*GReaSe-Core' }
Collection >> copyRemove: anObject [

	| old copy |
	old := self size.
	copy := self copyWithout: anObject.
	old = copy size ifTrue: [self errorNotFound: anObject].
	^ copy
]

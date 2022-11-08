Extension { #name : #SBCombinedCommand }

{ #category : #'*GReaSe-Components-BlockCode' }
SBCombinedCommand >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	self commands at: 1 ifPresent: [:command | command printOn: aStream].
	self commands allButFirstDo: [:command |
		aStream nextPutAll: ', '.
		command printOn: aStream].
	aStream nextPut: $).
]

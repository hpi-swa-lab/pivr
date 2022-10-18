Extension { #name : #SBCombinedCommand }

{ #category : #'*GS-VR-Editor' }
SBCombinedCommand >> vrDo [

	commands do: [:command | command vrDo]
]

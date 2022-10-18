Extension { #name : #SBTextCommand }

{ #category : #'*GS-VR-Editor' }
SBTextCommand >> vrDo [

	self assert: oldMorph = newMorph.
	SBVREditor current godotProvider setTextBlockContent: newText
		onTextBlockWithId: textMorph vrId.
	SBVREditor current addDirtyBlockId: textMorph owner containingToplevel vrId
]

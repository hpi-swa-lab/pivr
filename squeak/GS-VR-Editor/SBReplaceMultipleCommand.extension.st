Extension { #name : #SBReplaceMultipleCommand }

{ #category : #'*GS-VR-Editor' }
SBReplaceMultipleCommand >> vrDo [

	SBVREditor current godotProvider removeBlockWithId: target vrId.
	
	replacers reverseDo: [:morph |
		SBVREditor current godotProvider insertNewBlock: morph exportStructure asJsonString
			at: targetOldIndex
			inBlockWithId: targetOldOwner vrId.
		SBVREditor current addDirtyBlockId: morph containingToplevel vrId]
]

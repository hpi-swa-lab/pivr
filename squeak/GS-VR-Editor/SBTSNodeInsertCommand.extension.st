Extension { #name : #SBTSNodeInsertCommand }

{ #category : #'*GS-VR-Editor' }
SBTSNodeInsertCommand >> vrDo [

	morphs reverseDo: [:morph |
		SBVREditor current godotProvider insertNewBlock: morph exportStructure asJsonString
			at: index
			inBlockWithId: container vrId.
		SBVREditor current addDirtyBlockId: container containingToplevel vrId]
]

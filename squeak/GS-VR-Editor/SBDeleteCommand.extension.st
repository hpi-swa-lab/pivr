Extension { #name : #SBDeleteCommand }

{ #category : #'*GS-VR-Editor' }
SBDeleteCommand >> vrDo [

	SBVREditor current godotProvider removeBlockWithId: target vrId.
	oldOwner isSandblock ifTrue: [
		SBVREditor current addDirtyBlockId: oldOwner containingToplevel vrId]
]

{ #category : #'*GS-VR-Editor' }
SBDeleteCommand >> vrUndo [

	| vrNode |
	vrNode := target sandblockEditor treeRegistry treeFor: oldOwner.
	vrNode getParent addChild: vrNode afterIndex: oldIndex.
	vrNode relayout
]

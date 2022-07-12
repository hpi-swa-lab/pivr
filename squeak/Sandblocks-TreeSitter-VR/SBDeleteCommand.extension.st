Extension { #name : #SBDeleteCommand }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBDeleteCommand >> vrDo [

	| vrNode |
	vrNode := target sandblockEditor treeRegistry treeFor: target.
	vrNode getParent removeChild: vrNode
]

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBDeleteCommand >> vrUndo [

	| vrNode |
	vrNode := target sandblockEditor treeRegistry treeFor: oldOwner.
	vrNode getParent addChild: vrNode afterIndex: oldIndex.
	vrNode relayout
]

Extension { #name : #SBEditorOpenMorphCommand }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBEditorOpenMorphCommand >> vrDo [

	morph width: 500.
	editor godotProvider doOpenEditorMorphCommand: morph exportStructure asJsonString.
	"editor addDirtyBlockId: morph vrId"
]

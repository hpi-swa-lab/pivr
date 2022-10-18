Extension { #name : #SBEditorOpenMorphCommand }

{ #category : #'*GS-VR-Editor' }
SBEditorOpenMorphCommand >> vrDo [

	morph width: 500.
	editor godotProvider doOpenEditorMorphCommand: morph exportStructure asJsonString.
	"editor addDirtyBlockId: morph vrId"
]

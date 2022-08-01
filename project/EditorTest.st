Class {
	#name : #GDSEditorTest,
	#superclass : #GodotSpatial,
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSEditorTest >> appendText: text toNodeWithId: id [

	| block |
	block := (SBVREditor current morphAtVrId: id).
	block startInputAtEnd.
	text do: [:char |
		SBVREditor current handle: (SBTest keyboardEvent: char)].
	SBVREditor current cursor moveCursorDown
]

{ #category : #behavior }
GDSEditorTest >> blockInput: event on: targetId [

	| command target |
	event class = GodotInputEventMouseButton ifFalse: [^ self].
	
	self do: [
		target := SBVREditor current morphAtVrId: targetId.
		command := target parentSandblock deleteCommandFor: target.
		command ifNotNil: [SBVREditor current do: command]]
]

{ #category : #behavior }
GDSEditorTest >> do: aBlock [

	Project current addDeferredUIMessage: aBlock
]

{ #category : #behavior }
GDSEditorTest >> performInsertAtId: aNumber from: aBlockId [

	| command |
	command := SBVREditor current insertCommandAtId: aNumber.
	self do: [
		SBVREditor current do: command.
		(SBVREditor current morphAtVrId: aBlockId) deleteBlock]
]

{ #category : #behavior }
GDSEditorTest >> physicsProcess: delta [
	
	^ nil
]

{ #category : #behavior }
GDSEditorTest >> pickUpBlock: targetId [

	| command target |
	
	target := SBVREditor current morphAtVrId: targetId.
	SBVREditor current showInsertPositionsFor: target.
	self do: [
		command := target parentSandblock deleteCommandFor: target.
		command
			ifNotNil: [
				SBVREditor current do: command.
				SBVREditor current openMorphInView: target]
			ifNil: [
				target changeToUnknown.
				SBVREditor current openMorphInView: target]].
	^ targetId
]

{ #category : #behavior }
GDSEditorTest >> process: delta [

	SBVREditor current vrDoQueuedCommands
]

{ #category : #behavior }
GDSEditorTest >> ready [

	SBVREditor current
		godotProvider: (self getNodePath: 'Provider');
		openMorphInView: (SBTSSmalltalk parseToplevel: 'myMethod (1 to: 4) do: [:n | Transcript showln: n]' asString)
]

{ #category : #behavior }
GDSEditorTest >> selectCursorInBlockWithId: id at: pos [

	| block |
	block := SBVREditor current morphAtVrId: id.
	SBVREditor current cursor select: block.
]

{ #category : #behavior }
GDSEditorTest >> sendKeyStroke: character [

	| cursorPosition index |
	character do: [:char | | editor block |
		editor := SBVREditor current.
		editor handle: (SBTest keyboardEvent: char).
		cursorPosition := editor cursor cursorPosition.
		block := cursorPosition block.
		index := cursorPosition block currentTextMorph cursor.
		cursorPosition applyCommandIn: editor.
		editor cursor select: block.
		editor cursor selectedBlock currentTextMorph moveCursorTo: index].
]

{ #category : #behavior }
GDSEditorTest >> syncLayoutForBlockWithId: id [

	| editor |
	editor := SBVREditor current.
	editor godotProvider syncLayout:
		(editor morphAtVrId: id) exportStructure asJsonString.
]

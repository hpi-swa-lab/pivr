Class {
	#name : #GDSEditorTest,
	#superclass : #GodotSpatial,
	#instVars : [
		'tempMorph'
	],
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
GDSEditorTest >> compileBlockWithId: id [

	| block |
	block := SBVREditor current morphAtVrId: id.
	[block saveTryFixing: false quick: false] on: Error do: [^ false].
	^ true
]

{ #category : #behavior }
GDSEditorTest >> do: aBlock [

	Project current addDeferredUIMessage: aBlock
]

{ #category : #behavior }
GDSEditorTest >> getCategoryStrings [

	^ (SystemOrganization categories select: [:cat | 'Godot-*' match: cat]) asJsonString
]

{ #category : #behavior }
GDSEditorTest >> getClassStrings: aCategory [

	^ ((SystemOrganization classesIn: aCategory) collect: [:class | class asString]) asJsonString
]

{ #category : #behavior }
GDSEditorTest >> getCursorInfo [

	^ SBVREditor current cursor exportInfo ifNil: [nil] ifNotNil: [:info | info asJsonString]
]

{ #category : #behavior }
GDSEditorTest >> getCursorInfosForBlockWithId: id atPoint: gdVector2 [

	| block cursorPositions editor point |
	editor := SBVREditor current.
	block := editor morphAtVrId: id.
	point := gdVector2 x @ gdVector2 y.
	cursorPositions := editor cursor cursorsForBlock: block at: point.
	^ (cursorPositions collect: [:pos | pos exportInfo]) asJsonString
	
]

{ #category : #behavior }
GDSEditorTest >> getMethodStrings: aClassString [

	^ ((Smalltalk classNamed: aClassString) selectors) asJsonString
]

{ #category : #behavior }
GDSEditorTest >> openMethod: aMethodName inClass: aClassName [

	| class morph method |
	self do: [
		class := Smalltalk classNamed: aClassName.
		method := (class compiledMethodAt: aMethodName asSymbol).
		morph := SBTSStMethod for: method.
		SBVREditor current openMorphInView: morph.]
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
GDSEditorTest >> pickUpBlock: targetId showingInsertPositions: showInsertPositions [

	| command target |
	target := SBVREditor current morphAtVrId: targetId.
	showInsertPositions ifTrue:
		[SBVREditor current showInsertPositionsFor: target].
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

	SBVREditor current vrDoQueuedCommands.
]

{ #category : #behavior }
GDSEditorTest >> ready [

	self do: [
		SBVREditor current godotProvider: (self getNodePath: 'Provider')
		"openMorphInView: (SBTSSmalltalk parseToplevel: 'myMethod (1 to: 4) do: [:n | Transcript showln: n]' asString)"
		"openMorphInView: (SBTSSmalltalk parseToplevel:
			((GDSBouncingBall compiledMethodAt: #bounce:gravity:maxSpeed:) getSource string))"
		"openMorphInView: (SBTSSmalltalk parseToplevel: 'process
self print: ''i am bouncy''' asString)"]
]

{ #category : #behavior }
GDSEditorTest >> refreshAllInsertPositions [

	^ SBVREditor current refreshAllInsertPositions asJsonString
]

{ #category : #behavior }
GDSEditorTest >> selectCursorInBlockWithId: id at: pos [

	| block |
	block := SBVREditor current morphAtVrId: id.
	self do: [SBVREditor current cursor select: block]
]

{ #category : #behavior }
GDSEditorTest >> selectCursorInsertPosition: cursorId [

	| editor pos |
	self do: [
		editor := SBVREditor current.
		pos := editor insertPositionWithId: cursorId.
		editor cursor cursorPosition: pos explicitMove: true axis: #none.]
]

{ #category : #behavior }
GDSEditorTest >> sendKeyStroke: character [

	self do: [
		character do: [:char | | editor |
			editor := SBVREditor current.
			editor handle: (SBTest keyboardEvent: char).]]
]

{ #category : #behavior }
GDSEditorTest >> startInputAt: index inTextWithId: id [

	self do: [ | textMorph |
		textMorph := SBVREditor current morphAtVrId: id.
		SBVREditor current
			startInput: textMorph containingSandblock
			at: index
			replacingContents: false
			in: textMorph]
]

{ #category : #behavior }
GDSEditorTest >> syncLayoutForBlockWithId: id [

	| editor block |
	editor := SBVREditor current.
	block := (editor morphAtVrId: id).
	self do: [block layoutChanged;
		fullBounds].
	self flag: #performance. "doOneCycle per block probably wasterful"
	editor world doOneCycleNow.
	editor godotProvider syncLayout: block exportStructure asJsonString.
]

{ #category : #behavior }
GDSEditorTest >> tempCompileMethod [

	^ false
	"[GDSBouncingBall compile: tempMorph sourceString] on: Error do: [^ false].
	^ true"
]

{ #category : #behavior }
GDSEditorTest >> writeCharacter: character at: index inBlockWithId: id [

	| block editor |
	self do: [
		editor := SBVREditor current.
		block := editor morphAtVrId: id.
		character do: [:char |
		editor cursor select: block.
		editor cursor selectedBlock currentTextMorph moveCursorTo: index.
		editor handle: (SBTest keyboardEvent: char).
		"editor cursor cursorPosition applyCommandIn: editor."]]
]

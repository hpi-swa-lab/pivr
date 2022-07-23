Class {
	#name : #GDSEditorTest,
	#superclass : #GodotSpatial,
	#category : #'Godot-Scripts'
}

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
GDSEditorTest >> syncLayout [

	| editor structures |
	editor := SBVREditor current.
	structures := (editor vrIds collect: [:id | | morph |
		morph := editor morphAtVrId: id.
		id asString -> (morph exportStructure)]) as: Dictionary.
	editor godotProvider syncLayout: structures asJsonString
]

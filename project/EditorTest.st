Class {
	#name : #GDSEditorTest,
	#superclass : #GodotNode2D,
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSEditorTest >> physicsProcess: delta [
	
	^ nil
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

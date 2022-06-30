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
		openMorphInView: (SBTSSmalltalk parseToplevel: 'a 2 + 2' asString)
]

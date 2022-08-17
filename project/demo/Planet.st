Class {
	#name : #GDSPlanet,
	#superclass : #GDSVRObject,
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSPlanet >> physicsProcess: delta [
	
	^ nil
]

{ #category : #behavior }
GDSPlanet >> process: delta [

	^ nil
]

{ #category : #behavior }
GDSPlanet >> ready [
	
	self color: Color red
]

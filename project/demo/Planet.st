Class {
	#name : #GDSPlanet,
	#superclass : #GDSVRObject,
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSPlanet >> distance: aNumber [

	self translation: (GDVector3 newX: aNumber y: 0 z: 0)
]

{ #category : #behavior }
GDSPlanet >> physicsProcess: delta [
	
	^ nil
]

{ #category : #behavior }
GDSPlanet >> process: delta [

	| newTranslation |
	newTranslation := self translation rotatedAxis: (GDVector3 newX: 0 y: 1 z: 0) phi: (self speed * delta).
	self print: ('({1}, {2}, {3})' format: {newTranslation getAxis: 0. newTranslation getAxis: 1. newTranslation getAxis: 2}).
	self translation: newTranslation.
	self error: 'test error'.
]

{ #category : #behavior }
GDSPlanet >> ready [
	
	self color: Color red.
	self size: 0.1.
	
	self distance: 0.5.
]

{ #category : #behavior }
GDSPlanet >> speed [

	^ 0.1
]

{ #category : #behavior }
GDSPlanet >> speed: aNumber [

	speed := aNumber
]

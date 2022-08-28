Class {
	#name : #GDSPlanet,
	#superclass : #GDSVRObject,
	#instVars : [
		'speed'
	],
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

	| newTranslation angle |
	angle := 90 degreesToRadians.
	newTranslation := self translation rotatedAxis: (GDVector3 newX: 0 y: 1 z: 0) phi: angle.
	"self print: ('({1} {2})' format: {newX. newZ.})."
	self translate: (newTranslation * delta * self speed ).
]

{ #category : #behavior }
GDSPlanet >> ready [
	
	self color: Color red.
	self size: 0.1.
	self setSpeed: 1.0.
	
	self distance: 0.5.
]

{ #category : #behavior }
GDSPlanet >> setSpeed: aNumber [

	speed := aNumber.
]

{ #category : #behavior }
GDSPlanet >> speed [

	^ speed
]

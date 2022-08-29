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
GDSPlanet >> mass [

	| x |
	x := GDVector3 newX: 1 y: 0 z: 0.
	^ (self scale dotB: x) * (self size dotB: x)
]

{ #category : #behavior }
GDSPlanet >> process: delta [

	| newTranslation angle |
	angle := 90 degreesToRadians.
	newTranslation := self translation rotatedAxis: (GDVector3 newX: 0 y: 1 z: 0) phi: delta * speed * (self size dotB: self size).
	self translation: newTranslation
]

{ #category : #behavior }
GDSPlanet >> ready [
	
	self color: Color green.
	self setSize: 0.1.
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

{ #category : #behavior }
GDSPlanet >> speed: aNumber [

	speed := aNumber.
]

Class {
	#name : #GDSPlanet,
	#superclass : #GDSVRObject,
	#instVars : [
		'distance',
		'angle',
		'center'
	],
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSPlanet >> angle [

	^ angle
]

{ #category : #behavior }
GDSPlanet >> angle: radians [

	| pos |
	angle := radians.
	
	pos := (GDVector3 newX: self distance y: 0 z: 0)
		rotatedAxis: (GDVector3 newX: 0 y: 1 z: 0)
		phi: angle.
	
	self setTranslation: pos.
	
	
]

{ #category : #behavior }
GDSPlanet >> distance [

	^ distance
]

{ #category : #behavior }
GDSPlanet >> distance: aNumber [

	distance := aNumber
]

{ #category : #behavior }
GDSPlanet >> physicsProcess: delta [
	
	^ nil
]

{ #category : #behavior }
GDSPlanet >> process: delta [

	
]

{ #category : #behavior }
GDSPlanet >> ready [
	
	self color: Color red.
	self size: 0.1.
	
	self distance: 0.5.
	self angle: 0.
]

{ #category : #behavior }
GDSPlanet >> speed [

	^ 1
]

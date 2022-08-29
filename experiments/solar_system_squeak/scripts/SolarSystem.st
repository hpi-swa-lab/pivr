Class {
	#name : #GDSSolarSystem,
	#superclass : #GDSVRObject,
	#instVars : [
		'planets'
	],
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSSolarSystem >> process: delta [

	planets do: [:planet |
		planet setSpeed: (self getControllerSpeed * 100 * planet mass).
		planet setSize: (self getControllerTilt).]
]

{ #category : #behavior }
GDSSolarSystem >> ready [
	| newPlanet |
	
	planets := OrderedCollection new.
	1 to: 5 do: [:i | | r |
		newPlanet := (self getParent) createNewVRObject.
		planets add: newPlanet.
		self addChildNode: newPlanet.
		newPlanet distance: i * 0.3.
		newPlanet setSpeed: (1 to: 15) atRandom / 15.0.
		r := ThreadSafeRandom next * 0.2 + 0.05.
		newPlanet scale: (GDVector3 newX: r y: r z: r).]
]

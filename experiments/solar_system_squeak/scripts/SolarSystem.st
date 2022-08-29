Class {
	#name : #GDSSolarSystem,
	#superclass : #GDSVRObject,
	#instVars : [
		'planets'
	],
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSSolarSystem >> planets [

	^ planets
]

{ #category : #behavior }
GDSSolarSystem >> process: delta [
]

{ #category : #behavior }
GDSSolarSystem >> ready [
	| newPlanet |
	
	planets := OrderedCollection new.
	1 to: 5 do: [:i | 
		newPlanet := (self getParent) createNewVRObject.
		planets add: newPlanet.
		self addChildNode: newPlanet.
		newPlanet distance: i * 0.3.]
]

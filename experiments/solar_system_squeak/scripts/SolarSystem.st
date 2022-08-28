Class {
	#name : #GDSSolarSystem,
	#superclass : #GDSVRObject,
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSSolarSystem >> physicsProcess: delta [
	
	^ nil
]

{ #category : #behavior }
GDSSolarSystem >> process: delta [

	^ nil
]

{ #category : #behavior }
GDSSolarSystem >> ready [
	| newPlanet planetColor |
	
	"self color: Color yellow."
	1 to: 10 do: [:i |
		newPlanet := (self getParent) createNewVRObject.
		self addChildNode: newPlanet.
		newPlanet distance: i.
		newPlanet setSpeed: (1 to: 15) atRandom / 15.0.
		planetColor := Color r: 255 atRandom / 255.0 g: 255 atRandom / 255.0 b: 255 atRandom / 255.0.
		"newPlanet color: (Color r: 0.5 g: 0.1 b: 1.0)."]
]

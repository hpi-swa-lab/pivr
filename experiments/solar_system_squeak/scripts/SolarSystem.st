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
		planetColor := Color r: 255 atRandom / 255 g: 255 atRandom / 255 b: 255 atRandom / 255.
		newPlanet color: Color yellow.]
]

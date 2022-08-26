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
	
	self color: Color yellow
]

Class {
	#name : #GDSVRObject,
	#superclass : #GodotMeshInstance,
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSVRObject >> color: aColor [

	| col mat |
	mat := self getSurfaceMaterialSurface: 0.
	col := GDColor newRgbR: aColor red g: aColor green b: aColor blue.
	mat albedoColor: col.
]

{ #category : #behavior }
GDSVRObject >> physicsProcess: delta [
	
	^ nil
]

{ #category : #behavior }
GDSVRObject >> process: delta [
	
	^ nil
]

{ #category : #behavior }
GDSVRObject >> ready [
	
	^ nil
]

{ #category : #behavior }
GDSVRObject >> size: aNumber [

	self scale: (GDVector3 newX: aNumber y: aNumber z: aNumber)
]

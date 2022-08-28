Class {
	#name : #GDSVRObject,
	#superclass : #GodotSpatial,
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSVRObject >> color: aColor [

	| col mat |
	mat := self meshInstance getSurfaceMaterialSurface: 0.
	col := GDColor newRgbR: aColor red g: aColor green b: aColor blue.
	mat albedoColor: col.
]

{ #category : #behavior }
GDSVRObject >> meshInstance [

	^ self getNodePath: 'MeshInstance'
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

	self meshInstance scale: (GDVector3 newX: aNumber y: aNumber z: aNumber)
]

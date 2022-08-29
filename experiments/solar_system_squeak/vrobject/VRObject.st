Class {
	#name : #GDSVRObject,
	#superclass : #GodotSpatial,
	#instVars : [
		'last',
		'controllerSpeed'
	],
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSVRObject >> color: aColor [

	| mat |
	mat := self meshInstance getSurfaceMaterialSurface: 0.
	"col := GDColor newRgbR: aColor red g: aColor green b: aColor blue."
	mat albedoColor: aColor.
]

{ #category : #behavior }
GDSVRObject >> getControllerSpeed [

	^ controllerSpeed ifNil: [0.0]
]

{ #category : #behavior }
GDSVRObject >> getControllerTilt [

	| spatial |
	spatial := self getRightController.
	^ spatial getRotation dotB: (GDVector3 newX: 0 y: 0 z: 1).
]

{ #category : #behavior }
GDSVRObject >> getRightController [

	^ self getNodePath: '/root/Main/test'
	"'/root/EditorTest/Avater/FPController/RightHandController'"
]

{ #category : #behavior }
GDSVRObject >> meshInstance [

	^ self getNodePath: 'MeshInstance'
]

{ #category : #behavior }
GDSVRObject >> physicsProcess: delta [
	
	| spatial current |
	spatial := self getRightController.
	
	current := spatial getTranslation.
	controllerSpeed := last ifNotNil: [(last - current) length] ifNil: [0.0].
	last := current.
]

{ #category : #behavior }
GDSVRObject >> process: delta [
	
	
]

{ #category : #behavior }
GDSVRObject >> ready [
	
	^ nil
]

{ #category : #behavior }
GDSVRObject >> setSize: aNumber [

	self meshInstance scale: (GDVector3 newX: aNumber y: aNumber z: aNumber)
]

{ #category : #behavior }
GDSVRObject >> size [

	^ self meshInstance scale
]

Class {
	#name : #GDSVRObject,
	#superclass : #GodotSpatial,
	#instVars : [
		'last'
	],
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
GDSVRObject >> getControllerSpeed [

	| spatial current speed |
	spatial := self getRightController.
	
	current := spatial getTranslation.
	speed := last ifNotNil: [(last - current) length] ifNil: [0.0].
	last := current.
	^ speed
]

{ #category : #behavior }
GDSVRObject >> getControllerTilt [

	| spatial |
	spatial := self getRightController.
	^ spatial getRotation getAxis: 1
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

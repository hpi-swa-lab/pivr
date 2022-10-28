Class {
	#name : #FlyingCam,
	#superclass : #GRComponent,
	#category : #'Dworphic-BlockCode'
}

{ #category : #'as yet unclassified' }
FlyingCam >> render: props [

	^ (self godot: #Camera)
		script: 'res://addons/simple-free-look-camera-13dfef73af258bffe1ecc95343cda2d075fe8388/camera.gd';
		translation: (Vector3 x: 0 y: 0 z: 1)
]

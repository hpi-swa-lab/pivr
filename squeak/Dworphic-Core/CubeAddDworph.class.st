Class {
	#name : #CubeAddDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
CubeAddDworph >> collisionShape [

	^ GDBoxShape new extents: (self size / 2.0) asVector3
]

{ #category : #'as yet unclassified' }
CubeAddDworph >> render: props [

	^ ControllerToolDworph new
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		shape: self collisionShape;
		onRelease: #return;
		active: [(self methodAsComponent: #renderActive:) props: props];
		passive: [(self methodAsComponent: #renderPassive:) props: props]
]

{ #category : #'as yet unclassified' }
CubeAddDworph >> renderActive: props [

	| controllerTransform cubes |
	controllerTransform := self useProvidedRef: #controllerTransform.
	cubes := self useProvided: #cubes.
	self useTriggerPressedDo: [cubes set: [:c | c copyWith: {Color h: 360 atRandom s: 1 v: 1. controllerTransform get. UUID new asString}]].
	^ self renderPassive: props
]

{ #category : #'as yet unclassified' }
CubeAddDworph >> renderPassive: props [

	^ GDMeshInstance new mesh: (GDCubeMesh new
		size: self size asVector3;
		material: (GDSpatialMaterial new albedoColor: (Color r: 0.0 g: 1 b: 0.0)))
]

{ #category : #'as yet unclassified' }
CubeAddDworph >> size [

	^ 0.03
]

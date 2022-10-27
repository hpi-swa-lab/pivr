Class {
	#name : #CubeAddDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
CubeAddDworph >> collisionShape [

	^ GDBoxShape new extents: (self size / 2.0) asVector3
]

{ #category : #'as yet unclassified' }
CubeAddDworph >> render: props [

	| cubes |
	cubes := self useProvided: #cubes.
	^ GRGrabbableArea new
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		children: {
			GDCollisionShape new shape: self collisionShape.
			GDMeshInstance new mesh: (GDCubeMesh new
				size: self size asVector3;
				material: (GDSpatialMaterial new albedoColor: (Color r: 0.0 g: 1 b: 0.0)))};
		onRelease: [:event | props at: #transform ifAbsent: [nil]];
		onButtonPress: [:event | event isTrigger ifTrue: [cubes set: [:c | c copyWith: {Color h: 360 atRandom s: 1 v: 1. event transform. UUID new asString}]]]
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

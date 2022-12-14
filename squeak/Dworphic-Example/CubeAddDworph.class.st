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

	^ props extract: [:transform | | cubes |
		cubes := self useProvided: #cubes.
		GRGrabbableArea new
			transform: (transform ifNil: [Matrix4x4 identity]);
			children: {
				GDCollisionShape new shape: self collisionShape.
				GDMeshInstance new mesh: (GDCubeMesh new
					size: self size asVector3;
					material: (GDSpatialMaterial new albedoColor: (Color r: 0.0 g: 1 b: 0.0)))};
			onButtonPress: [:event | event isTrigger ifTrue: [cubes set: [:c | c copyWith: {Color h: 360 atRandom s: 1 v: 1. event transform. UUID new asString}]]]]
]

{ #category : #'as yet unclassified' }
CubeAddDworph >> size [

	^ 0.03
]

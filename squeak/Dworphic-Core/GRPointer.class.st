Class {
	#name : #GRPointer,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRPointer class >> detectorRadius [

	^ 0.1
]

{ #category : #'as yet unclassified' }
GRPointer class >> laserLength [

	^ 100
]

{ #category : #'as yet unclassified' }
GRPointer class >> laserRadius [

	^ 0.005
]

{ #category : #'as yet unclassified' }
GRPointer >> length [

	^ self class laserLength
]

{ #category : #'as yet unclassified' }
GRPointer >> render: props [

	| overlappingAreas |
	overlappingAreas := self useState: OrderedCollection new.
	overlappingAreas get.
	
	^ GRActingArea new
		point: true;
		touch: false;
		handRef: (props at: #handRef);
		children: {
			GDCollisionShape new
				rotation: 0 @ Float pi @ 0;
				shape: (GDRayShape new length: self class laserLength).
			GDArea new
				monitorable: false;
				collisionLayer: 0;
				collisionMask: GRInteractiveArea pointLayer;
				onAreaEntered: [:area | overlappingAreas set: [:old | old copyWith: area]];
				onAreaExited: [:area | overlappingAreas set: [:old | old copyRemove: area]];
				rotation: Float pi / 2 @ 0 @ 0;
				translation: 0 @ 0 @ (self length * -0.5);
				children: {
					GDCollisionShape new shape: (GDCylinderShape new
						height: self class laserLength;
						radius: self class detectorRadius)}.
			GDMeshInstance new
				visible: overlappingAreas get notEmpty;
				rotation: Float pi / 2 @ 0 @ 0;
				translation: 0 @ 0 @ (self length * -0.5);
				mesh: (GDCylinderMesh new
					height: self length;
					topRadius: self class laserRadius;
					bottomRadius: self class laserRadius;
					material: (GDSpatialMaterial new albedoColor: (Color r: 1 g: 0.0 b: 0.0)))}
]

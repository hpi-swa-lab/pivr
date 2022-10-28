Class {
	#name : #GRPointer,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRPointer >> render: props [

	| length areaRef transform |
	length := props at: #length ifAbsent: [10].
	
	transform := self useState: Matrix4x4 identity.
	areaRef := self useGodotRef.
	self useActiveEventHandlersFor: areaRef side: (props at: #side) transform: transform controller: nil.
	
	^ GDArea new
		ref: areaRef;
		children: {
			GDCollisionShape new shape: (GDRayShape new length: length).
			GDMeshInstance new
				rotation: Float pi / 2 @ 0 @ 0;
				translation: 0 @ 0 @ length / 2;
				mesh: (GDCylinderMesh new
					bottomRadius: 0.01;
					topRadius: 0.01;
					height: length;
					material: (GDSpatialMaterial new
						albedoColor: ((Color r: 1 g: 0.0 b: 0.0) alpha: 0.5);
						flagsTransparent: true))}
]

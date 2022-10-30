Class {
	#name : #GRPointer,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRPointer >> render: props [

	| overlappingAreas |
	overlappingAreas := self useState: OrderedCollection new.
	overlappingAreas get.
	
	^ GRActingArea new
		point: true;
		touch: false;
		side: (props at: #side ifAbsent: [#none]);
		actingTransform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		controllerRef: (props at: #controllerRef ifAbsent: [nil]);
		setHandlers: (props at: #setHandlers);
		children: {
			GDCollisionShape new
				rotation: 0 @ Float pi @ 0;
				shape: (GDRayShape new length: 3).
			GDArea new
				collisionLayer: 0;
				collisionMask: GRInteractiveArea pointLayer;
				onAreaEntered: [:area | overlappingAreas set: [:old | old copyWith: area]];
				onAreaExited: [:area | overlappingAreas set: [:old | old copyRemove: area]];
				rotation: Float pi / 2 @ 0 @ 0;
				translation: 0 @ 0 @ -1.5;
				children: {
					GDCollisionShape new shape: (GDCylinderShape new
						height: 3;
						radius: 0.1)}.
			GDMeshInstance new
				visible: overlappingAreas get notEmpty;
				rotation: Float pi / 2 @ 0 @ 0;
				translation: 0 @ 0 @ -1.5;
				mesh: (GDCylinderMesh new
					height: 3;
					topRadius: 0.005;
					bottomRadius: 0.005;
					material: (GDSpatialMaterial new albedoColor: (Color r: 1 g: 0.0 b: 0.0)))}
]

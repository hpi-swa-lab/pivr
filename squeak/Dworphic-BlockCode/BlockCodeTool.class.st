Class {
	#name : #BlockCodeTool,
	#superclass : #GRComponent,
	#category : #'Dworphic-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeTool >> render: props [

	props extract: [:transform | | currentTransform overlappingAreas |
		currentTransform := self useState: Matrix4x4 identity.
		self useEffect: [currentTransform set: (transform ifNil: Matrix4x4 identity)] dependencies: #().
		
		overlappingAreas := self useState: #().
		
		^ GRDraggableArea new
		transform: currentTransform get;
		onRelease: [:event | currentTransform set: event transform];
		touch: true;
		point: false;
		children: {
			GDCollisionShape new
				shape: (GDCylinderShape new
					height: 20cm;
					radius: 1cm).
			GDMeshInstance new
				mesh: (GDCylinderMesh new
					height: 20cm;
					bottomRadius: 1cm;
					topRadius: 2mm).
			GDArea new
				onAreaEntered: [:area | overlappingAreas set: [:old | old copyWith: area]];
				onAreaEntered: [:area | overlappingAreas set: [:old | old copyWithout: area]];
				translation: 0 @ (0.5m + 10cm) @ 0;
				children: {
					GDCollisionShape new
						shape: (GDCylinderShape new
							height: 1m;
							radius: 3cm)}.
			GDMeshInstance new
				"visible: overlappingAreas get notEmpty;"
				translation: 0 @ (0.5m + 10cm) @ 0;
				mesh: (GDCylinderMesh new
					height: 1m;
					bottomRadius: 1mm;
					topRadius: 1mm;
					material: (GDSpatialMaterial new
						albedoColor: Color magenta))}]
]

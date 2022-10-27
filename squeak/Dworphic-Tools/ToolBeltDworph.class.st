Class {
	#name : #ToolBeltDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Tools'
}

{ #category : #'as yet unclassified' }
ToolBeltDworph >> render: props [

	| head |
	head := SBToggledCode
		comment: ''
		active: 2
		do: {[-1 @ 0.5 @ -1]. [self useHeadTransform translation]}.
	^ GDMeshInstance new
		translation: head - (0 @ 0.5 @ 0.05);
		mesh: (GDCubeMesh new size: 0.2 @ 0.07 @ 0.01);
		children: {
			GDSpatial new
				children: VirtualKeyboardDworph new;
				translation: -0.08 @ 0.04 @ 0.
			GDSpatial new
				children: AirwriteDworph new;
				translation: -0.04 @ 0.03 @ 0.
			GDSpatial new
				children: CubeAddDworph new;
				translation: 0.0 @ 0.03 @ 0.
			GDSpatial new
				children: CubeRemoveDworph new;
				translation: 0.04 @ 0.03 @ 0.
			GDSpatial new
				children: TeleportToolDworph new;
				translation: 0.08 @ 0.04 @ 0}
]

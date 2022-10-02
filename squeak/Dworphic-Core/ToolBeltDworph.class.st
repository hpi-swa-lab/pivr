Class {
	#name : #ToolBeltDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
ToolBeltDworph >> render: props [

	| head |
	head := SBToggledCode
		comment: ''
		active: 2
		do: {[-1 @ 0.5 @ -1]. [self useHeadTransform translation]}.
	^ (self godot: #MeshInstance)
		translation: head - (0 @ 0.5 @ 0.05);
		mesh: ((self godot: #CubeMesh) size: 0.2 @ 0.07 @ 0.01);
		children: {
			(self godot: #Spatial)
				children: {VirtualKeyboardDworph new};
				translation: -0.08 @ 0.04 @ 0.
			(self godot: #Spatial)
				children: {AirwriteDworph new};
				translation: -0.04 @ 0.03 @ 0.
			(self godot: #Spatial)
				children: {CubeAddDworph new};
				translation: 0.0 @ 0.03 @ 0.
			(self godot: #Spatial)
				children: {CubeRemoveDworph new};
				translation: 0.04 @ 0.03 @ 0.
			(self godot: #Spatial)
				children: {TeleportToolDworph new};
				translation: 0.08 @ 0.04 @ 0}
]

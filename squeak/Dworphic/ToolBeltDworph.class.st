Class {
	#name : #ToolBeltDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #'as yet unclassified' }
ToolBeltDworph >> render: props [

	| head |
	head := self useHeadTransform translation.
	^ (self godot: #MeshInstance)
		translation: head - (0 @ 0.4 @ 0.05);
		mesh: ((self godot: #CubeMesh) size: 0.2 @ 0.07 @ 0.01);
		children: {
			(self godot: #Spatial)
				children: {AirwriteDworph new};
				translation: -0.02 @ 0.03 @ 0.
			(self godot: #Spatial)
				children: {CubeAddDworph new};
				translation: 0.02 @ 0.03 @ 0.
			(self godot: #Spatial)
				children: {CubeRemoveDworph new};
				translation: 0.04 @ 0.03 @ 0}
]

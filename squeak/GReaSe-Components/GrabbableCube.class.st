Class {
	#name : #GrabbableCube,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GrabbableCube >> render: props [

	| color |
	color := self useState: Color red.

	^ InteractiveArea new
		onHover: [:controllerNode | color set: Color yellow];
		onBlur: [:controllerNode | color set: Color red];
		onGrab: [:controllerNode | color set: Color green];
		onRelease: [:controllerNode | color set: Color yellow];
		children: {
			GDCollisionShape new
				shape: GDBoxShape new.
			GDMeshInstance new
				mesh: (GDCubeMesh new
					material: (GDSpatialMaterial new
						albedoColor: color get))}
]

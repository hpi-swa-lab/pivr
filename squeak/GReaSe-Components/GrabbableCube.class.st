Class {
	#name : #GrabbableCube,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GrabbableCube >> render: props [

	| color |
	color := self useState: Color red.

	^ GRInteractiveArea new
		onHover: [:event | Transcript showln: 'cube hover ', event side. color set: Color yellow];
		onBlur: [:event | Transcript showln: 'cube blur ', event side. color set: Color red];
		onGrab: [:event | Transcript showln: 'cube grab ', event side. color set: Color green];
		onRelease: [:event | Transcript showln: 'cube release ', event side. color set: Color yellow];
		children: {
			GDCollisionShape new
				shape: GDBoxShape new.
			GDMeshInstance new
				mesh: (GDCubeMesh new
					material: (GDSpatialMaterial new
						albedoColor: color get))}
]

Class {
	#name : #GrabbableCube,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GrabbableCube >> render: props [

	| color |
	color := self useState: Color red.

	^ GRGrabbableArea new
		onHover: [:event | Transcript showln: 'cube hover ', event side. color set: Color yellow];
		onBlur: [:event | Transcript showln: 'cube blur ', event side. color set: Color red];
		onGrab: [:event | Transcript showln: 'cube grab ', event side. color set: Color green];
		onRelease: [:event | Transcript showln: 'cube release ', event side. color set: Color yellow];
		onButtonPress: [:event | Transcript showln: 'cube button press ', event button];
		onButtonRelease: [:event | Transcript showln: 'cube button release ', event button];
		"translation: 1 @ 1 @ 1.5;"
		scale: 0.2 asVector3;
		children: {
			GDCollisionShape new
				shape: GDBoxShape new.
			GDMeshInstance new
				mesh: (GDCubeMesh new
					material: (GDSpatialMaterial new
						albedoColor: color get))}
]

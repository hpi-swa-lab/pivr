Class {
	#name : #DebugDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
DebugDworph >> render: props [

	| label |
	label := props
		at: #label
		ifPresent: [:text |
			GDLabel3D new
				text: text;
				fixedSize: true;
				billboard: GDSpatialMaterial billboardEnabled;
				noDepthTest: true;
				pixelSize: 0.0035;
				modulate: (Color r: 1 g: 0.4 b: 1);
				offset: 0 @ 10]
		ifAbsent: [nil].
	^ GDMeshInstance new
		mesh: (GDCubeMesh new
			size: 0.02 @ 0.02 @ 0.02;
			material: (GDSpatialMaterial new
				albedoColor: (Color r: 1 g: 0.4 b: 1);
				flagsNoDepthTest: true));
		globalTranslation: (props at: #point);
		children: label
]

Class {
	#name : #CodeBlockText,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
CodeBlockText >> render: props [

	| layoutParams |
	layoutParams := (props at: #layoutParams).
	^ GDSpatial new
		children: {
		GDLabel3D new
			text: ((props at: #morph) contents);
			"Add a tiny little offset to the label translation to prevent z-fighting"
			translation: (Vector3 x: 0 y: 0 z: layoutParams blockDepth / 2) + 0.0001;
			pixelSize: layoutParams morphicScale}
]

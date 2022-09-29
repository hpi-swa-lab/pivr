Class {
	#name : #CodeBlockText,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
CodeBlockText >> render: props [

	| layoutParams |
	layoutParams := (props at: #layoutParams).
	^ (self godot: #Spatial)
		children: {
			(self godot: #Label3D)
				text: ((props at: #structure) at: #contents);
				"Add a tiny little offset to the label translation to prevent z-fighting"
				translation: (Vector3 x: 0 y: 0 z: layoutParams blockDepth / 2) + 0.0001;
				pixel_size: layoutParams morphicScale}
]

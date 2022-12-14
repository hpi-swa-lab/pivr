Class {
	#name : #MidiChannelArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Midi-World'
}

{ #category : #'as yet unclassified' }
MidiChannelArea class >> colors [

	^ {Color red. Color blue. Color green. Color yellow. Color magenta}
]

{ #category : #'as yet unclassified' }
MidiChannelArea >> render: props [

	props extract: [:translation :channel | | channelAreas ref |
		ref := self useGodotRef.
		channelAreas := self useProvided: #channelAreas.
		self useEffect: [channelAreas at: ref put: channel] dependencies: #().
		
		^ GDMeshInstance new
			translation: translation + (0 @ 1m @ 0);
			mesh: (GDCylinderMesh new
				height: 2m;
				topRadius: 1m;
				bottomRadius: 1m;
				material: (GDSpatialMaterial new
					flagsTransparent: true;
					paramsCullMode: GDSpatialMaterial cullDisabled;
					albedoColor: ((self class colors at: channel) alpha: 0.5)));
			children: {
				GDArea new
					ref: ref;
					spaceOverride: GDArea spaceOverrideReplace;
					gravityPoint: true;
					gravityVec: 0 asVector3;
					linearDamp: 0.9;
					angularDamp: 0.9;
					children: {
						GDCollisionShape new
							shape: (GDCylinderShape new
								height: 2m;
								radius: 1m)}}]
]

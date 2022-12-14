Class {
	#name : #MidiBlock,
	#superclass : #GRComponent,
	#category : #'Dworphic-Midi-World'
}

{ #category : #'as yet unclassified' }
MidiBlock >> render: props [

	| grabbed globalTransform channelAreas channelMapping currentChannel ref instrument setChannelMapping |
	grabbed := self useState: false.
	globalTransform := self useState: (Matrix4x4 withOffset: 0 @ 2 @ 0).
	channelAreas := self useProvided: #channelAreas.
	currentChannel := self useState: nil.
	channelMapping := self useProvided: #channelMapping.
	setChannelMapping := self useProvided: #setChannelMapping.
	ref := self useGodotRef.
	instrument := props at: #instrument.
	
	^ GDRigidBody new
		ref: ref;
		globalTransform: globalTransform get;
		mode: (grabbed get ifTrue: [GDRigidBody modeStatic] ifFalse: [GDRigidBody modeRigid]);
		children: {
			GDCollisionShape new shape: (GDBoxShape new extents: 5 cm asVector3).
			GRGrabbableArea new
				point: true;
				touch: true;
				transform: Matrix4x4 identity;
				onGrab: [grabbed set: true];
				onRelease: [:event |
					grabbed set: false.
					globalTransform set: event transform];
				children: {
					self cubeOfSize: 10 cm color: (Color r: 0.0 g: 0.0 b: 1).
					GDArea new
						onAreaEntered: [:area |
							channelAreas associations detect: [:assoc | assoc key get = area] ifFound: [:assoc | | channel |
								channel := assoc value.
								setChannelMapping value: [:old |
									old copy
										at: instrument put: channel;
										yourself].
								currentChannel set: channel]];
						onAreaExited: [:area |
							setChannelMapping value: [:old |
								old copy
									at: instrument put: nil;
									yourself].
							currentChannel set: nil];
						children: {GDCollisionShape new shape: (GDBoxShape new extents: 5 cm asVector3)}}}
]

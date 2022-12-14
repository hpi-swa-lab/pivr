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
		mode: (grabbed get ifTrue: [GDRigidBody modeStatic]  ifFalse: [GDRigidBody modeRigid]);
		children: {
			GDCollisionShape new
				shape: (
					GDBoxShape new
						extents: 5cm asVector3).
			GRGrabbableArea new
				transform: Matrix4x4 identity;
				onGrab: [grabbed set: true];
				onRelease: [:event |
					grabbed set: false.
					globalTransform set: event transform];
				children: {
					(self cubeOfSize: 10cm color: Color blue).
					GDArea new
						onAreaEntered: [:area | | foundAreas |
							foundAreas := channelAreas associations select: [:assoc |
								assoc key get = area].
							foundAreas ifNotEmpty: [ | channel |
								channel := foundAreas first value.
								setChannelMapping value: [:old | old copy at: instrument put: channel; yourself].
								currentChannel set: channel.]];
						onAreaExited: [:area |
							setChannelMapping value: [:old | old copy at: instrument put: nil; yourself].
							currentChannel set: nil];
						children: {
							GDCollisionShape new
								shape: (
									GDBoxShape new
										extents: 5cm asVector3)}}}
]

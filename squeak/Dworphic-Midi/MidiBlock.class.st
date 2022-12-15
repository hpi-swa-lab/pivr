Class {
	#name : #MidiBlock,
	#superclass : #GRComponent,
	#category : #'Dworphic-Midi-World'
}

{ #category : #'as yet unclassified' }
MidiBlock >> render: props [

	^ props extract: [:onAssignChannel :onTransform :instrument :globalTransform | | grabbed channelAreas |
		grabbed := self useState: false.
		channelAreas := self useProvided: #channelAreas.
		
		GDRigidBody new
			globalTransform: globalTransform;
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
						onTransform value: event transform];
					children: {
						self cubeOfSize: 10 cm color: (Color r: 0.0 g: 0.0 b: 1).
						GDArea new
							onAreaEntered: [:area |
								channelAreas associations
									detect: [:assoc | assoc key get = area]
									ifFound: [:assoc | onAssignChannel value: assoc value]];
							onAreaExited: [:area | onAssignChannel value: nil];
							children: {GDCollisionShape new shape: (GDBoxShape new extents: 5 cm asVector3)}}}]
]

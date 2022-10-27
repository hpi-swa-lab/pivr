Class {
	#name : #CubeDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
CubeDworph >> render: props [

	| grabbed rigidBodyRef |
	grabbed := self useState: false.
	rigidBodyRef := self useGodotRef.
	
	^ GDRigidBody new
		ref: rigidBodyRef;
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		children: {
			GDCollisionShape new shape: (GDBoxShape new extents: 0.05 asVector3).
			GRGrabbableArea new
				onGrab: [grabbed set: true];
				onRelease: [:event |
					grabbed set: false.
					rigidBodyRef get transform: event transform.
					Matrix4x4 identity];
				children: {
					GDCollisionShape new shape: (GDBoxShape new extents: 0.05 asVector3).
					self cubeOfSize: 0.1 color: (props at: #color)}}
]

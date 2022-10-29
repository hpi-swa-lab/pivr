Class {
	#name : #CubeDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
CubeDworph >> render: props [

	| rigidBodyRef |
	rigidBodyRef := self useGodotRef.
	
	^ GDRigidBody new
		ref: rigidBodyRef;
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		children: {
			GDCollisionShape new shape: (GDBoxShape new extents: 0.05 asVector3).
			GRGrabbableArea new
				sqmeta_id: (props at: #id);
				transform: Matrix4x4 identity;
				onRelease: [:event | rigidBodyRef get transform: event transform];
				children: {
					GDCollisionShape new shape: (GDBoxShape new extents: 0.05 asVector3).
					self cubeOfSize: 0.1 color: (props at: #color)}}
]

Class {
	#name : #CubeDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
CubeDworph >> render: props [

	| rigidBodyRef api |
	rigidBodyRef := self useGodotRef.
	api := Dictionary new.
	
	^ GDRigidBody new
		ref: rigidBodyRef;
		meta: #id set: (props at: #id);
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		children: {
			GDCollisionShape new shape: (GDBoxShape new extents: 0.05 asVector3).
			GRGrabbableArea new
				api: api;
				transform: Matrix4x4 identity;
				onGrab: [:event | (api at: #setGrabOffset) value: event transform inverseTransformation * rigidBodyRef get globalTransform];
				onRelease: [:event | rigidBodyRef get transform: event transform];
				children: {
					GDCollisionShape new shape: (GDBoxShape new extents: 0.05 asVector3).
					self cubeOfSize: 0.1 color: (props at: #color)}}
]

Class {
	#name : #DworphicGrabbableTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #tests }
DworphicGrabbableTest >> testCantGrabMultiple [

	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape1'.
				GDSpatial new}.
			GRGrabbableArea new children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape2'.
				GDSpatial new}}].
	
	self tick: {
		(godotTree firstNodeNamed: 'shape1') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	self assert: ((godotTree firstNodeNamed: 'shape1') hasParent: (self controllerNode: #left)).
	
	self tick: {
		(godotTree firstNodeNamed: 'shape2') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	self deny: ((godotTree firstNodeNamed: 'shape2') hasParent: (self controllerNode: #left))
]

{ #category : #tests }
DworphicGrabbableTest >> testExitAndGrab [

	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape1'.
				GDSpatial new}.
			GRGrabbableArea new children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape2'.
				GDSpatial new}}].
	
	self tick: {
		(godotTree firstNodeNamed: 'shape1') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	
	self tick: {
		(self controllerNode: #left)
			signal: #'button_release'
			with: {GDGlobalConstants joyVrGrip}.
		(godotTree firstNodeNamed: 'shape1') parent
			signal: #'area_exited'
			with: {self controllerCollider: #left}}.
	
	self tick: {
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	self deny: ((godotTree firstNodeNamed: 'shape1') hasParent: (self controllerNode: #left))
]

{ #category : #tests }
DworphicGrabbableTest >> testGrab [

	Transcript showln: '-------------------------------'.
	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new
				handle: 1;
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}}].
	
	self deny: ((godotTree firstNodeNamed: 'shape') hasParent: (self controllerNode: #left)).
	
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}}.
	self tick: {
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	
	self assert: Matrix4x4 identity equals: (godotTree firstNodeNamed: 'shape') parent transform.
	self assert: ((godotTree firstNodeNamed: 'shape') hasParent: (self controllerNode: #left)).
	
	self tick: {
		(self controllerNode: #left)
			subscribe: #transform
			set: (Matrix4x4 withOffset: 1 @ 2 @ 3)}.
	self tick: {
		(self controllerNode: #left)
			signal: #'button_release'
			with: {GDGlobalConstants joyVrGrip}}.
	
	self
		assert: (Matrix4x4 withOffset: 1 @ 2 @ 3)
		equals: (godotTree firstNodeNamed: 'shape') parent transform.
	self deny: ((godotTree firstNodeNamed: 'shape') hasParent: (self controllerNode: #left))
]

{ #category : #tests }
DworphicGrabbableTest >> testGrabAndRelease [

	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape1'.
				GDSpatial new}.
			GRGrabbableArea new children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape2'.
				GDSpatial new}}].
	
	self tick: {
		(godotTree firstNodeNamed: 'shape1') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	self assert: ((godotTree firstNodeNamed: 'shape1') hasParent: (self controllerNode: #left)).
	
	self tick: {
		(self controllerNode: #left)
			signal: #'button_release'
			with: {GDGlobalConstants joyVrGrip}.
		(godotTree firstNodeNamed: 'shape1') parent
			signal: #'area_exited'
			with: {self controllerCollider: #left}}.
	self deny: ((godotTree firstNodeNamed: 'shape1') hasParent: (self controllerNode: #left)).
	
	self tick: {
		(godotTree firstNodeNamed: 'shape2') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	self assert: ((godotTree firstNodeNamed: 'shape2') hasParent: (self controllerNode: #left))
]

{ #category : #tests }
DworphicGrabbableTest >> testGrabLock [

	self assert: false
]

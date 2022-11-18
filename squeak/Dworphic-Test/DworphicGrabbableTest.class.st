Class {
	#name : #DworphicGrabbableTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #tests }
DworphicGrabbableTest >> testCantGrabMultiple [

	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new
				handle: 1;
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape1'.
					GDSpatial new}.
			GRGrabbableArea new
				handle: 2;
				children: {
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
			GRGrabbableArea new
				handle: 1;
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape1'.
					GDSpatial new}.
			GRGrabbableArea new
				handle: 2;
				children: {
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
	
	"self
		assert: (Matrix4x4 withOffset: 1 @ 2 @ 3)
		equals: (godotTree firstNodeNamed: 'shape') parent transform."
	self deny: ((godotTree firstNodeNamed: 'shape') hasParent: (self controllerNode: #left))
]

{ #category : #tests }
DworphicGrabbableTest >> testGrabAndRelease [

	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new
				handle: 1;
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape1'.
					GDSpatial new}.
			GRGrabbableArea new
				handle: 2;
					children: {
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

	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new
				handle: 1;
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape1'.
					GDSpatial new}.
			GRGrabbableArea new
				handle: 2;
					children: {
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
DworphicGrabbableTest >> testHandleSurvivesRemount [

	self assert: false
]

{ #category : #tests }
DworphicGrabbableTest >> testMakesHandRefExclusive [

	| pressed |
	pressed := false.
	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new
				handle: 1;
				name: 'grabArea';
				onButtonPress: [:event |
					event button = 99 ifTrue: [
						pressed := true]];
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}.
			}].
	
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {99}.
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_exited'
			with: {self controllerCollider: #left}}.
			
	self assert: pressed.
]

{ #category : #tests }
DworphicGrabbableTest >> testOnGrabBegin [

	| grabbed |
	grabbed := false.
	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new
				handle: 1;
				onGrabBegin: [grabbed := true];
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}.
			}].
		
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
			
	self assert: grabbed.
]

{ #category : #tests }
DworphicGrabbableTest >> testOnGrabEndButtonRelease [

	| released |
	released := false.
	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new
				handle: 1;
				onGrabEnd: [released := true];
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}.
			}].
		
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.}.
		self tick: {(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}.}.
		self tick: {(self controllerNode: #left)
			signal: #'button_release'
			with: {GDGlobalConstants joyVrGrip}}.
			
	self assert: released.
]

{ #category : #tests }
DworphicGrabbableTest >> testOnGrabEndUnmountContainer [

	| released toggleableGrabbableArea toggleableGrabbableAreaContainer |
	released := false.
	toggleableGrabbableArea := self conditionalComponent: [
		GRGrabbableArea new
			handle: 1;
			onRelease: [released := true];
			children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape'.}]
		default: true.
	toggleableGrabbableAreaContainer := self conditionalComponent: [
		GRDraggableAreaContainer new
			children: {toggleableGrabbableArea second}]
		default: true.
	
	self openComponent: [
		WorldDworph new children: {
			toggleableGrabbableAreaContainer second}].
		
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	
	toggleableGrabbableArea first value: false.
	self tick.	
	self assert: released not.

	toggleableGrabbableAreaContainer first value: false.
	self tick.
	self assert: released.
]

{ #category : #tests }
DworphicGrabbableTest >> testOnGrabEndUnmountSelf [

	| released toggleAndGrabbableArea |
	released := false.
	toggleAndGrabbableArea := self conditionalComponent: [
		GRGrabbableArea new
			handle: 1;
			onGrabEnd: [released := true];
			children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape'.
				GDSpatial new}] default: true.
	self openComponent: [
		WorldDworph new
			children: {toggleAndGrabbableArea second}].
		
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	
	toggleAndGrabbableArea first value: false.
	self tick.
	
	self assert: released.
]

{ #category : #tests }
DworphicGrabbableTest >> testReleaseLockUnmountContainer [

	| released toggleableGrabbableArea toggleableGrabbableAreaContainer |
	released := false.
	toggleableGrabbableArea := self conditionalComponent: [
		GRGrabbableArea new
			handle: 1;
			onRelease: [released := true];
			children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape'.}]
		default: true.
	toggleableGrabbableAreaContainer := self conditionalComponent: [
		GRDraggableAreaContainer new
			children: {toggleableGrabbableArea second}]
		default: true.
	
	self openComponent: [
		WorldDworph new children: {
			toggleableGrabbableAreaContainer second}].
		
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	
	toggleableGrabbableArea first value: false.
	self tick.	
	self assert: released not.

	toggleableGrabbableAreaContainer first value: false.
	self tick.
	self assert: released.
]

{ #category : #tests }
DworphicGrabbableTest >> testReleaseLockUnmountSelf [

	| toggleAndGrabbableArea grabbed |
	grabbed := false.
	toggleAndGrabbableArea := self conditionalComponent: [
		GRGrabbableArea new
			handle: 1;
			children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape1'.
				GDSpatial new}] default: true.
	self openComponent: [
		WorldDworph new
			children: {
				toggleAndGrabbableArea second.
				GRGrabbableArea new
					handle: 2;
					onGrabBegin: [grabbed := true];
					children: {
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
			with: {GDGlobalConstants joyVrGrip}.
		(godotTree firstNodeNamed: 'shape2') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	
	self assert: grabbed not.
	toggleAndGrabbableArea first value: false.
	self tick: {
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	
	self assert: grabbed.
]

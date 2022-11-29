Class {
	#name : #DworphicGrabbableTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #failures }
DworphicGrabbableTest >> expectedFailures [

	^ #(testOnGrabEndUnmountContainer)
]

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
	
	self deny: ((godotTree firstNodeNamed: 'shape') hasParent: (self controllerNode: #left)).
	self
		assert: (Matrix4x4 withOffset: 1 @ 2 @ 3)
		equals: (godotTree firstNodeNamed: 'shape') parent transform
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
DworphicGrabbableTest >> testGrabOnlyOnGrip [

	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new
				handle: 1;
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}}].
	
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}}.
	self tick: {
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrTrigger}}.
			
	self deny: ((godotTree firstNodeNamed: 'shape') hasParent: (self controllerNode: #left)).
]

{ #category : #tests }
DworphicGrabbableTest >> testHandleSurvivesRemount [

	| toggleableGrabbableArea released |
	released := false.
	toggleableGrabbableArea := self conditionalComponent: [
		GRGrabbableArea new
			handle: 1;
			releaseCondition: #containerUnmount;
			name: 'area';
			children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape1'.}]
		default: true.
	
	self openComponent: [
		WorldDworph new children: {
			GRDraggableAreaContainer new
				children: {toggleableGrabbableArea second}}].
	
	self tick: {
		(godotTree firstNodeNamed: 'shape1') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left) toggleGrip: true}.
	
	toggleableGrabbableArea first value: false.
	self tick.	
	toggleableGrabbableArea first value: true.
	self tick.
	
	self assert: ((godotTree firstNodeNamed: 'area') hasParent: (self controllerNode: #left)).
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
DworphicGrabbableTest >> testManualGrab [

	| timesCalled |
	timesCalled := 0.
	self openComponent: [
		WorldDworph new children: {
			[ | api |
				api := Dictionary new.
				
				GRDraggableArea new
					api: api;
					onButtonPress: [:e | e isBY ifTrue: [(api at: #startGrab) value: e]];
					onGrab: [timesCalled := timesCalled + 1];
					children: {
						GDCollisionShape new
							shape: GDBoxShape new;
							name: 'shape'.
						GDSpatial new}] asComponent}].
	
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}}.
	self tick: {(self controllerNode: #left) toggleBY: true}.
	self tick.
	self tick: {(self controllerNode: #left) toggleGrip: false}.
	
	self assert: 1 equals: timesCalled
]

{ #category : #tests }
DworphicGrabbableTest >> testManualRelease [

	| shouldRelease timesCalled |
	timesCalled := 0.
	shouldRelease := false.
	self openComponent: [
		WorldDworph new children: {[ | api |
			api := Dictionary new.
			CMFReact useEffect: [
				shouldRelease ifTrue: [(api at: #endGrab) value]]
				dependencies: {shouldRelease}.
			
			GRDraggableArea new
				api: api;
				onRelease: [timesCalled := timesCalled + 1];
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}.
			] asComponent}].
		
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left) toggleGrip: true}.
	shouldRelease := true.
	self tick.
	self tick: {(self controllerNode: #left) toggleGrip: false}.
			
	self assert: 1 equals: timesCalled.
]

{ #category : #tests }
DworphicGrabbableTest >> testOffsetTransform [

	self openComponent: [ | t |
		t := CMFReact useState: (Matrix4x4 withOffset: 0 @ 1 @ 0).
		WorldDworph new children: {
			GRGrabbableArea new
				transform: t get;
				onRelease: [:e | t set: e transform];
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'}}].
	
	self tick: {
		(self controllerNode: #left)
			subscribe: #transform
			set: (Matrix4x4 withOffset: 0 @ 0.75 @ 0)}.
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left) toggleGrip: true}.
	self
		assert: (Matrix4x4 withOffset: 0 @ 0.25 @ 0)
		equals: (godotTree firstNodeNamed: 'shape') parent transform.
	
	self tick: {
		(self controllerNode: #left)
			subscribe: #transform
			set: (Matrix4x4 withOffset: 0 @ 1.75 @ 0)}.
	self tick: {(self controllerNode: #left) toggleGrip: false}.
	self
		assert: (Matrix4x4 withOffset: 0 @ 2 @ 0)
		equals: (godotTree firstNodeNamed: 'shape') parent transform
]

{ #category : #tests }
DworphicGrabbableTest >> testOnGrabBegin [

	| grabbed |
	grabbed := false.
	self openComponent: [
		WorldDworph new children: {
			GRGrabbableArea new
				handle: 1;
				onGrab: [grabbed := true];
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
				onRelease: [released := true];
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

	| toggleableGrabbableArea toggleableGrabbableAreaContainer released |
	released := false.
	toggleableGrabbableArea := self conditionalComponent: [
		GRGrabbableArea new
			handle: 1;
			releaseCondition: #containerUnmount;
			onGrabEnd: [released := true];
			children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape1'.}]
		default: true.
	toggleableGrabbableAreaContainer := self conditionalComponent: [
		GRDraggableAreaContainer new
			children: {toggleableGrabbableArea second}]
		default: true.
	
	self openComponent: [
		WorldDworph new children: {
			toggleableGrabbableAreaContainer second}].
	
	self tick: {
		(godotTree firstNodeNamed: 'shape1') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left) toggleGrip: true}.
	toggleableGrabbableArea first value: false.
	self tick.	
	self tick: {
		(self controllerNode: #left) toggleGrip: true}.
	
	self deny: released.

	toggleableGrabbableAreaContainer first value: false.
	self tick.
	self tick: {
		(self controllerNode: #left) toggleGrip: true}.
	
	self assert: released.
]

{ #category : #tests }
DworphicGrabbableTest >> testOnGrabEndUnmountSelf [

	| released toggleAndGrabbableArea |
	released := false.
	toggleAndGrabbableArea := self conditionalComponent: [
		GRGrabbableArea new
			handle: 1;
			onRelease: [released := true];
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

	| toggleableGrabbableArea toggleableGrabbableAreaContainer grabbed |
	grabbed := false.
	toggleableGrabbableArea := self conditionalComponent: [
		GRGrabbableArea new
			handle: 1;
			releaseCondition: #containerUnmount;
			children: {
				GDCollisionShape new
					shape: GDBoxShape new;
					name: 'shape1'.}]
		default: true.
	toggleableGrabbableAreaContainer := self conditionalComponent: [
		GRDraggableAreaContainer new
			children: {toggleableGrabbableArea second}]
		default: true.
	
	self openComponent: [
		WorldDworph new children: {
			toggleableGrabbableAreaContainer second.
			GRGrabbableArea new
					handle: 2;
					onGrab: [grabbed := true];
					children: {
						GDCollisionShape new
							shape: GDBoxShape new;
							name: 'shape2'}}].
	
	self tick: {
		(godotTree firstNodeNamed: 'shape1') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left) toggleGrip: true.
		(godotTree firstNodeNamed: 'shape2') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}.
		(self controllerNode: #left) toggleGrip: true}.
	
	self deny: grabbed.
	
	toggleableGrabbableArea first value: false.
	self tick.	
	self tick: {
		(self controllerNode: #left) toggleGrip: true}.
	
	self deny: grabbed.

	toggleableGrabbableAreaContainer first value: false.
	self tick.
	self tick: {
		(self controllerNode: #left) toggleGrip: true}.
	
	self assert: grabbed.
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
					onGrab: [grabbed := true];
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
	
	self deny: grabbed.
	toggleAndGrabbableArea first value: false.
	self tick. "make sure that the first area unmounts"
	self tick: {
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	
	self assert: grabbed.
]

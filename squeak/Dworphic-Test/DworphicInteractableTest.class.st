Class {
	#name : #DworphicInteractableTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #tests }
DworphicInteractableTest >> testAxisChanged [

	| strength |
	strength := nil.
	self openComponent: [
		WorldDworph new children: {
			GRInteractiveArea new
				touch: true;
				onAxisChange: [:event |
					self assert: event isGrip.
					strength := event strength];
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}}].
	
	self tick: {
		(self controllerNode: #left)
			signal: #'button_release'
			with: {GDGlobalConstants joyVrAnalogGrip}}.
	
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}}.
	self tick: {
		(self controllerNode: #left)
			subscribeCall: #'get_joystick_axis'
			index: 0
			with: 0.3}.
	self assert: 0.3 equals: strength
]

{ #category : #tests }
DworphicInteractableTest >> testBlur [

	| blur |
	blur := false.
	self openComponent: [
		WorldDworph new children: {
			GRInteractiveArea new
				touch: true;
				onHover: [blur := true];
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
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_exited'
			with: {self controllerCollider: #left}}.
	self assert: blur
]

{ #category : #tests }
DworphicInteractableTest >> testButtonPress [

	| press |
	press := false.
	self openComponent: [
		WorldDworph new children: {
			GRInteractiveArea new
				touch: true;
				onButtonPress: [:event |
					self assert: event button = GDGlobalConstants joyVrGrip.
					press := true];
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}}].
	
	self tick: {
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	self deny: press.
	
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}}.
	self tick: {
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrGrip}}.
	self assert: press
]

{ #category : #tests }
DworphicInteractableTest >> testButtonRelease [

	| release |
	release := false.
	self openComponent: [
		WorldDworph new children: {
			GRInteractiveArea new
				touch: true;
				onButtonRelease: [:event |
					self assert: event button = GDGlobalConstants joyVrGrip.
					release := true];
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}}].
	
	self tick: {
		(self controllerNode: #left)
			signal: #'button_release'
			with: {GDGlobalConstants joyVrGrip}}.
	self deny: release.
	
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}}.
	self tick: {
		(self controllerNode: #left)
			signal: #'button_release'
			with: {GDGlobalConstants joyVrGrip}}.
	self assert: release
]

{ #category : #'as yet unclassified' }
DworphicInteractableTest >> testHook [

	| pressed released |
	pressed := false.
	released := false.
	self openComponent: [
		WorldDworph new children: [
			GRComponent basicNew
				useButtonPress: [:e | pressed := true]
				release: [:e | released := true]
				axisChange: [:e | ]
				side: #left.
			nil] asComponent].
	self tick: {(self controllerNode: #left) toggleTrigger: true}.
	self assert: pressed.
	self deny: released.
	
	self tick: {(self controllerNode: #left) toggleTrigger: false}.
	self assert: released
]

{ #category : #tests }
DworphicInteractableTest >> testHover [

	| hovered |
	hovered := false.
	self openComponent: [
		WorldDworph new children: {
			GRInteractiveArea new
				touch: true;
				onHover: [hovered := true];
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}}].
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {self controllerCollider: #left}}.
	self assert: hovered
]

Class {
	#name : #DworphicInteractableTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #tests }
DworphicInteractableTest >> testBlur [

	| blur |
	blur := false.
	self openComponent: [
		WorldDworph new children: {
			GRInteractiveArea new
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

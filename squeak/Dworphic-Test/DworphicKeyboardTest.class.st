Class {
	#name : #DworphicKeyboardTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #'as yet unclassified' }
DworphicKeyboardTest >> testPressKey [

	| a |
	self openComponent: [
		WorldDworph new children: {
			VirtualKeyboardDworph new.
			GDSpatial new
				children: TextInputDworph new;
				name: 'a'}].
	
	self tick: (self pointAndTrigger: (godotTree firstNodeThat: [:n | n godotClass = #Area and: [n hasParentNamed: 'a']])).
	
	a := (godotTree firstNodeThat: [:node | node godotClass = #Label3D and: [node text = 'A']]) parent.
	self tick: {
		a signal: #'area_entered' with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrTrigger}}.
	self assert: 'A' equals: (godotTree firstNodeOfType: #LineEdit) text
]

{ #category : #'as yet unclassified' }
DworphicKeyboardTest >> testRenderKeyboard [

	self openComponent: [
		WorldDworph new children: {
			VirtualKeyboardDworph new.
			GDSpatial new
				children: TextInputDworph new;
				name: 'a'}].
	self tick: (self pointAndTrigger: (godotTree firstNodeThat: [:n | n godotClass = #Area and: [n hasParentNamed: 'a']]))
]

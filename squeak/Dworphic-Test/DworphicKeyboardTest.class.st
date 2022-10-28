Class {
	#name : #DworphicKeyboardTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #'as yet unclassified' }
DworphicKeyboardTest >> testPressKey [

	| a |
	self openComponent: [WorldDworph new children: {VirtualKeyboardDworph new}].
	a := (godotTree firstNodeThat: [:node | node godotClass = #Label3D and: [node text = 'A']]) parent.
	self tick: {
		a signal: #'area_entered' with: {self controllerCollider: #left}.
		(self controllerNode: #left)
			signal: #'button_pressed'
			with: {GDGlobalConstants joyVrTrigger}}.
	self assert: (self remoteCalls anySatisfy: [:call | call second = 'parse_input_event']).
	self assert: (self remoteCalls anySatisfy: [:call | call second = 'scancode' and: [call third = $A asInteger]])
]

{ #category : #'as yet unclassified' }
DworphicKeyboardTest >> testRenderKeyboard [

	self openComponent: [WorldDworph new children: {VirtualKeyboardDworph new}]
]

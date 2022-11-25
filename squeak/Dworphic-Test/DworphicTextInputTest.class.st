Class {
	#name : #DworphicTextInputTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #'as yet unclassified' }
DworphicTextInputTest >> testChangeFocus [

	| a b |
	self openComponent: [
		WorldDworph new children: {
			GDSpatial new
				children: TextInputDworph new;
				name: 'a'.
			GDSpatial new
				children: TextInputDworph new;
				name: 'b'}].
	a := [godotTree firstNodeThat: [:n | n godotClass = #Area and: [n hasParentNamed: 'a']]].
	b := [godotTree firstNodeThat: [:n | n godotClass = #Area and: [n hasParentNamed: 'b']]].
	self tick: {
		a value signal: #'area_entered' with: {self pointerCollider: #right}.
		(self controllerNode: #right) toggleTrigger: true}.
	self assert: #() equals: ((a value firstNodeOfType: #LineEdit) properties at: 'sqcall_grab_focus').
	
	self tick: {
		b value signal: #'area_entered' with: {self pointerCollider: #right}.
		(self controllerNode: #right) toggleTrigger: true}.
	
	self assert: nil equals: ((a value firstNodeOfType: #LineEdit) properties at: 'sqcall_grab_focus').
	self assert: #() equals: ((a value firstNodeOfType: #LineEdit) properties at: 'sqcall_release_focus').
	self assert: #() equals: ((b value firstNodeOfType: #LineEdit) properties at: 'sqcall_grab_focus')
]

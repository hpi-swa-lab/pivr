Class {
	#name : #DworphicTextInputTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #tests }
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
	self tick: (self pointAndTrigger: a value).
	self assert: #() equals: ((a value firstNodeOfType: #LineEdit) properties at: 'sqcall_grab_focus').
	
	self tick: (self pointAndTrigger: b value).
	
	self assert: nil equals: ((a value firstNodeOfType: #LineEdit) properties at: 'sqcall_grab_focus').
	self assert: #() equals: ((a value firstNodeOfType: #LineEdit) properties at: 'sqcall_release_focus').
	self assert: #() equals: ((b value firstNodeOfType: #LineEdit) properties at: 'sqcall_grab_focus')
]

{ #category : #tests }
DworphicTextInputTest >> testEnterText [

	| keyA field |
	self openComponent: [
		WorldDworph new children: {
			GDSpatial new
				children: TextInputDworph new;
				name: 'field'.
			VirtualKeyboardDworph new}].
	
	field := [godotTree firstNodeThat: [:n | n godotClass = #Area and: [n hasParentNamed: 'field']]].
	self tick: (self pointAndTrigger: field value).
	
	keyA := [(godotTree firstNodeThat: [:node | node godotClass = #Label3D and: [node text = 'A']]) parent].
	self tick: (self pointAndTrigger: keyA value).
	
	self assert: 'A' equals: (field value firstNodeOfType: #LineEdit) text
]

{ #category : #tests }
DworphicTextInputTest >> testOpensKeyboardOnFocus [

	| shiftKey |
	self openComponent: [
		WorldDworph new children: {
			GDSpatial new
				children: TextInputDworph new;
				name: 'a'.
			VirtualKeyboardDworph new}].
	
	shiftKey := [godotTree firstNodeThat: [:node | (node properties includesKey: 'text') and: [node text = 'Shift']]].
	self shouldRaiseError: shiftKey.
	self tick: (self pointAndTrigger: (godotTree firstNodeThat: [:n | n godotClass = #Area and: [n hasParentNamed: 'a']])).
	self tick: {
		(godotTree firstNodeWithProp: 'sqsubscribe_rect_size')
			subscribe: 'rect_size'
			set: {100. 50}.
		(godotTree firstNodeThat: [:n | (n properties includesKey: 'sqsubscribe_global_transform') and: [n godotClass = #MeshInstance]])
			subscribe: 'global_transform'
			set: (Matrix4x4 withOffset: 20 @ 10 @ 0)}.
	self shouldnt: shiftKey raise: Error.
	self assert: ((Matrix4x4 withOffset: 20 @ 9.9 @ 0.05) translation closeTo: ((shiftKey value parentOfType: #Area) parentOfType: #Area) transform translation)
]

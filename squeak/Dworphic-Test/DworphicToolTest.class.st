Class {
	#name : #DworphicToolTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #'as yet unclassified' }
DworphicToolTest >> testCanUseControllerIndependentHooksInTool [

	| controller |
	self openComponentBlock: [
		WorldDworph new children: {
			ControllerToolDworph new
				shape: (self godot: #CollisionShape);
				active: [
					[
						GRComponent useProvided: #controllerTransform.
						self godot: #Active] asReactNodeBuilder build];
				passive: [self godot: #Passive]}].
	
	controller := godotTree firstNodeThat: [:node | (node properties at: #'controller_id' ifAbsent: nil) == 2].
	
	self tick: {
		controller signal: #'button_pressed' with: {6}.
		(godotTree firstNodeThat: [:node | node properties includesKey: #'area_entered'])
			signal: #'area_entered'
			with: {controller firstNodeOfType: #Area}}
]

{ #category : #'as yet unclassified' }
DworphicToolTest >> testCantGrabMultipleThings [

	self openComponentBlock: [
		WorldDworph new children: {
			ControllerToolDworph new
				shape: (self godot: #CollisionShape);
				active: [self godot: #Active1];
				passive: [self godot: #Passive1].
			ControllerToolDworph new
				shape: (self godot: #CollisionShape);
				active: [self godot: #Active2];
				passive: [self godot: #Passive2]}].
	
	self tick: {
		(self controllerNode: #right) toggleGrip: true.
		((godotTree firstNodeOfType: #Passive1) orParentOfType: #Area)
			signal: #'area_entered'
			with: {self controllerCollider: #right}}.
	godotTree firstNodeOfType: #Active1.
	
	self tick: {
		((godotTree firstNodeOfType: #Passive2) orParentOfType: #Area)
			signal: #'area_entered'
			with: {self controllerCollider: #right}}.
	self should: [godotTree firstNodeOfType: #Active2] raise: Error
]

{ #category : #'as yet unclassified' }
DworphicToolTest >> testKeyboardNoRenderLoop [
	"smoke test for openingi keyboard (plus, there used to be a bug where the useEffect/setState combo in the keyboard would cause an infinite render loop"
	<timeout: 0.1>

	self openComponentBlock: [WorldDworph new children: {VirtualKeyboardDworph new}].
	
	self tick: {
		(self controllerNode: #right) toggleGrip: true.
		(godotTree firstNodeThat: [:node | node properties includesKey: #'area_entered'])
			signal: #'area_entered'
			with: {self controllerCollider: #right}}
]

{ #category : #'as yet unclassified' }
DworphicToolTest >> testReleaseToolStayOrReturn [

	| releasePos initialPos |
	initialPos := 1 @ 2 @ 3.
	releasePos := 4 @ 5 @ 6.
	{{#return. initialPos}. {#stay. releasePos}} do: [:pair |
		self openComponentBlock: [
			WorldDworph new children: {
				ControllerToolDworph new
					shape: (self godot: #CollisionShape);
					transform: (Matrix4x4 withOffset: initialPos);
					onRelease: pair first;
					active: [self godot: #Active];
					passive: [self godot: #Passive]}].
		self tick: {
			(self controllerNode: #right) toggleGrip: true.
			((godotTree firstNodeOfType: #Passive) orParentOfType: #Area)
				signal: #'area_entered'
				with: {self controllerCollider: #right}.
			(self controllerNode: #right) setGlobalTransform: (Matrix4x4 withOffset: releasePos)}.
		self tick: {(self controllerNode: #right) toggleGrip: false}.
		self
			assert: pair second
			equals: ((godotTree firstNodeOfType: #Passive) orParentOfType: #Area) transform translation]
]

{ #category : #'as yet unclassified' }
DworphicToolTest >> testRightHandVsLeftHand [

	| rightTransform leftTransform |
	self openComponentBlock: [
		WorldDworph new children: {
			ControllerToolDworph new
				onRelease: #drop;
				shape: (self godot: #CollisionShape);
				active: [self godot: #Active];
				passive: [self godot: #Passive]}].
	
	self should: [godotTree firstNodeOfType: #Active] raise: Error.
	
	rightTransform := Matrix4x4 withOffset: 1 @ 2 @ 3.
	leftTransform := Matrix4x4 withOffset: 3 @ 4 @ 5.
	self tick: {
		(self controllerNode: #right) setGlobalTransform: rightTransform.
		(self controllerNode: #left) setGlobalTransform: leftTransform.
		((godotTree firstNodeOfType: #Passive) orParentOfType: #Area)
			signal: #'area_entered'
			with: {self controllerCollider: #left}}.
	
	self tick: {(self controllerNode: #right) toggleGrip: true}.
	self should: [godotTree firstNodeOfType: #Active] raise: Error.
	
	self tick: {(self controllerNode: #left) toggleGrip: true}.
	self shouldnt: [godotTree firstNodeOfType: #Active] raise: Error.
	
	self tick: {(self controllerNode: #left) toggleGrip: false}.
	self should: [godotTree firstNodeOfType: #Active] raise: Error.
	self
		assert: leftTransform
		equals: ((godotTree firstNodeOfType: #Passive) parent parent properties at: #transform)
]

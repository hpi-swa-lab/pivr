Class {
	#name : #DworphicToolTest,
	#superclass : #GRTestCase,
	#category : #'GReaSe-Test'
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
			(godotTree firstNodeOfType: #ARVRController)
				signal: #'button_pressed'
				with: {6}.
			(godotTree firstNodeThat: [:node | node properties includesKey: #'area_entered'])
				signal: #'area_entered'
				with: {godotTree firstNodeOfType: #Area}.
			(godotTree firstNodeOfType: #ARVRController)
				subscribe: #'global_transform'
				set: (Matrix4x4 withOffset: releasePos)}.
		self tick: {
			(godotTree firstNodeOfType: #ARVRController)
				signal: #'button_release'
				with: {6}}.
		self
			assert: pair second
			equals: ((godotTree firstNodeOfType: #Passive) parent properties at: #transform) translation]
]

Class {
	#name : #SBTSVRTest,
	#superclass : #CMFReactComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
SBTSVRTest >> render: props [

	| rightControllerTransform leftTransformSubscription leftControllerTransform rightTransformSubscription rightJoystickPressed headTransform headTransformSubscription string enterKey |
	rightJoystickPressed := self useState: false.
	
	string := self useState: ''.
	leftControllerTransform := self useState: Matrix4x4 identity.
	rightControllerTransform := self useState: Matrix4x4 identity.
	headTransform := self useState: Matrix4x4 identity.
	
	enterKey := self useCallback: [:key | string set: [:s | s, key asString]] dependencies: {}.
	leftTransformSubscription := self
		useCallback: [:transform | leftControllerTransform set: transform]
		dependencies: {}.
	rightTransformSubscription := self
		useCallback: [:transform | rightControllerTransform set: transform]
		dependencies: {}.
	headTransformSubscription := self
		useCallback: [:transform | headTransform set: transform]
		dependencies: {}.
	
	^ GRProvider
		values: {
			#keyEntered -> enterKey.
			#leftControllerTransform -> leftControllerTransform get.
			#rightControllerTransform -> rightControllerTransform get.
			#rightJoystickPressed -> rightJoystickPressed get.
			#headTransform -> headTransform get}
		children: {
			(self godot: #Spatial) children: {
				(self godot: #GRVRRoot) children: {
					(self godot: #ARVROrigin) children: {
						(self godot: #ARVRCamera) subscribeTo: #transform do: headTransformSubscription.
						(self godot: #ARVRController)
							controller_id: 1;
							children: {
								(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh) size: (Vector3 x: 0.01 y: 0.01 z: 0.01)).
								(self godot: #Label3D) text: string get};
							subscribeTo: #transform do: leftTransformSubscription.
						(self godot: #ARVRController)
							controller_id: 2;
							children: {
								(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh)
									size: (Vector3 x: 0.01 y: 0.01 z: 0.01);
									material: ((self godot: #SpatialMaterial) albedo_color: (Color r: 1 g: 0.0 b: 0.0)))};
							subscribeTo: #transform do: rightTransformSubscription;
							button_pressed: [:which | rightJoystickPressed set: true];
							button_release: [:which | rightJoystickPressed set: false].
						SBTSAirwrite asReactNodeBuilder build}}}}
]

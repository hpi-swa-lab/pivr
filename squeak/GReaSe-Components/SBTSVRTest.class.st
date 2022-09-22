Class {
	#name : #SBTSVRTest,
	#superclass : #CMFReactComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
SBTSVRTest >> render: props [

	| rightControllerTransform leftTransformSubscription leftControllerTransform rightTransformSubscription rightJoystickPressed |
	rightJoystickPressed := self useState: false.
	
	leftControllerTransform := self useState: Matrix4x4 identity.
	rightControllerTransform := self useState: Matrix4x4 identity.
	
	leftTransformSubscription := self
		useCallback: [:transform | leftControllerTransform set: transform]
		dependencies: {}.
	rightTransformSubscription := self
		useCallback: [:transform | rightControllerTransform set: transform]
		dependencies: {}.
	
	^ SBTSLeftControllerTransform
		asProviderNodeWithValue: leftControllerTransform get
		children: {
			SBTSRightControllerTransform
				asProviderNodeWithValue: rightControllerTransform get
				children: {
					SBTSRightJoystickPressed
						asProviderNodeWithValue: rightJoystickPressed get
						children: {
							(self godot: #Spatial) children: {
								(self godot: #GRVRRoot) children: {
									(self godot: #ARVROrigin) children: {
										self godot: #ARVRCamera.
										(self godot: #ARVRController)
											controller_id: 1;
											children: {(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh) size: (Vector3 x: 0.01 y: 0.01 z: 0.01))};
											subscribeTo: #transform do: leftTransformSubscription.
										(self godot: #ARVRController)
											controller_id: 2;
											children: {
												(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh)
													size: (Vector3 x: 0.01 y: 0.01 z: 0.01);
													material: ((self godot: #SpatialMaterial) albedo_color: Color red))};
											subscribeTo: #transform do: rightTransformSubscription;
											button_pressed: [:which | rightJoystickPressed set: true];
											button_release: [:which | rightJoystickPressed set: false].
										SBTSAirwrite asReactNodeBuilder build}}}}}}
]

Class {
	#name : #DworphicWorld,
	#superclass : #CMFReactComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
DworphicWorld >> render: props [

	| rightControllerTransform leftTransformSubscription leftControllerTransform rightTransformSubscription rightJoystickPressed headTransform headTransformSubscription leftControllerPortal buttonPressed buttonRelease |
	rightJoystickPressed := self useState: false.
	
	leftControllerTransform := self useState: Matrix4x4 identity.
	rightControllerTransform := self useState: Matrix4x4 identity.
	headTransform := self useState: Matrix4x4 identity.
	
	buttonPressed := self useCallback: [:which | rightJoystickPressed set: true] dependencies: {}.
	buttonRelease := self useCallback: [:which | rightJoystickPressed set: false] dependencies: {}.
	leftTransformSubscription := self
		useCallback: [:transform | leftControllerTransform set: transform]
		dependencies: {}.
	rightTransformSubscription := self
		useCallback: [:transform | rightControllerTransform set: transform]
		dependencies: {}.
	headTransformSubscription := self
		useCallback: [:transform | headTransform set: transform]
		dependencies: {}.
	leftControllerPortal := self useRef: nil.
	
	^ GRProvider
		values: {
			#leftControllerTransform -> leftControllerTransform get.
			#rightControllerTransform -> rightControllerTransform get.
			#rightJoystickPressed -> rightJoystickPressed get.
			#headTransform -> headTransform get.
			#leftControllerPortal -> leftControllerPortal get}
		children: {
			(self godot: #Spatial) children: {
				(self godot: #GRVRRoot) children: {
					(self godot: #ARVROrigin) children: {
						(self godot: #ARVRCamera) subscribeTo: #transform do: headTransformSubscription.
						(self godot: #ARVRController)
							controller_id: 1;
							children: (props at: #leftControllerChildren ifAbsent: [#()]), {(self godot: #Spatial) ref: [:node | leftControllerPortal set: node]};
							subscribeTo: #transform do: leftTransformSubscription.
						(self godot: #ARVRController)
							controller_id: 2;
							children: (props at: #rightControllerChildren ifAbsent: [#()]);
							subscribeTo: #transform do: rightTransformSubscription;
							button_pressed: buttonPressed;
							button_release: buttonRelease}, (props at: #children ifAbsent: [#()])}}}
]

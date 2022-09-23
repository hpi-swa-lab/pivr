Class {
	#name : #WorldDworph,
	#superclass : #CMFReactComponent,
	#category : #Dworphic
}

{ #category : #'as yet unclassified' }
WorldDworph >> render: props [

	| rightControllerTransform leftTransformSubscription leftControllerTransform rightTransformSubscription rightJoystickPressed headTransform headTransformSubscription leftControllerPortal buttonPressed buttonRelease rightControllerPortal |
	self useVR.
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
	rightControllerPortal := self useRef: nil.
	
	^ GRProvider
		values: {
			#leftControllerTransform -> leftControllerTransform get.
			#rightControllerTransform -> rightControllerTransform get.
			#rightJoystickPressed -> rightJoystickPressed get.
			#headTransform -> headTransform get.
			#leftControllerPortal -> leftControllerPortal get.
			#rightControllerPortal -> rightControllerPortal get}
		children: {
			(self godot: #ARVROrigin) children: {
				(self godot: #ARVRCamera) subscribeTo: #transform do: headTransformSubscription.
				(self godot: #ARVRController)
					controller_id: 1;
					children: (props at: #leftControllerChildren ifAbsent: [#()]), {(self godot: #Spatial) ref: [:node | leftControllerPortal set: node]};
					subscribeTo: #transform do: leftTransformSubscription.
				(self godot: #ARVRController)
					controller_id: 2;
					children: (props at: #rightControllerChildren ifAbsent: [#()]), {(self godot: #Spatial) ref: [:node | rightControllerPortal set: node]};
					subscribeTo: #transform do: rightTransformSubscription;
					button_pressed: buttonPressed;
					button_release: buttonRelease}, (props at: #children ifAbsent: [#()])}
]

{ #category : #'as yet unclassified' }
WorldDworph >> useVR [

	self
		useEffect: [ | openxr |
			openxr := GRReactCurrentSession value
				callOn: 'ARVRServer'
				method: 'find_interface'
				arguments: {'OpenXR'}.
			openxr ifNotNil: [ | sceneTree viewport |
				GRReactCurrentSession value
					callOn: openxr
					method: 'initialize'
					arguments: {}.
				sceneTree := GRReactCurrentSession value
					callOn: 'Engine'
					method: 'get_main_loop'
					arguments: {}.
				viewport := GRReactCurrentSession value get: 'root' of: sceneTree.
				GRReactCurrentSession value set: 'hdr' of: viewport to: false.
				GRReactCurrentSession value set: 'vsync_enabled' of: 'OS' to: true.
				GRReactCurrentSession value set: 'iterations_per_second' of: 'Engine' to: 90.
				GRReactCurrentSession value set: 'arvr' of: viewport to: true].
			nil]
		dependencies: {}
]

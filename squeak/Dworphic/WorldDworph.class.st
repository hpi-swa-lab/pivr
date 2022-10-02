Class {
	#name : #WorldDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #'rendering - simulated' }
WorldDworph >> mouseSensitivity [

	^ 0.25
]

{ #category : #'rendering - simulated' }
WorldDworph >> positionInSceneFor: aPoint spatialRef: aRef do: aBlock [

	| session sceneTree viewport camera origin normal state |
	session := GRReactCurrentSession value.
	sceneTree := session callOn: 'Engine' method: 'get_main_loop' arguments: {}.
	viewport := session get: 'root' of: sceneTree.
	camera := session callOn: viewport method: 'get_camera'.
	origin := session callOn: camera method: #'project_ray_origin' arguments: {aPoint}.
	normal := (session callOn: camera method: #'project_ray_normal' arguments: {aPoint}) * 100.
	state := session get: #'direct_space_state' of: (session callOn: aRef get method: #'get_world').
	(session
		callOn: state
		method: #'intersect_ray'
		arguments: {origin. normal. {}. 2147483647. true. true}) ifNotEmpty: [:res | aBlock value: (res at: #position)]
]

{ #category : #rendering }
WorldDworph >> render: props [

	^ (self methodAsComponent: #renderSimulated:) props: props
]

{ #category : #'rendering - simulated' }
WorldDworph >> renderControllerControls: props [

	| buttonCallback ref controllerTransform keyboardCallback pressedButtons trigger |
	ref := self useRef: nil.
	
	controllerTransform := self useProvided: #setControllerTransform.
	pressedButtons := self useProvided: #setPressedButtons.
	trigger := self useProvided: #triggerSet.
	
	buttonCallback := self
		useCallback: [:pressed :button :position |
			self
				positionInSceneFor: position
				spatialRef: ref
				do: [:point | controllerTransform set: (Matrix4x4 withOffset: point)]]
		dependencies: {}.
	
	keyboardCallback := self
		useCallback: [:pressed :key :name |
			name = 'Space' ifTrue: [
				pressed
					ifTrue: [pressedButtons set: [:b | b copyWith: ControllerInfoDworph grip]]
					ifFalse: [pressedButtons set: [:b | b copyWithout: ControllerInfoDworph grip]]].
			name = 'Tab' ifTrue: [pressed ifTrue: [trigger set: 1.0] ifFalse: [trigger set: 0.0]]]
		dependencies: {}.
	
	^ (self godot: #Spatial)
		ref: ref;
		children: {
			(self godot: #GREvents)
				button: buttonCallback;
				keyboard: keyboardCallback}
]

{ #category : #'rendering - simulated' }
WorldDworph >> renderFirstPersonControls: props [

	| transform mouseSub totalPitch isMouseLocked buttonCallback keyboardCallback moving |
	transform := props at: #transform.
	
	isMouseLocked := self useState: false.
	moving := self useState: 0.
	totalPitch := self useRef: 0.
	
	self
		useEffect: [
			GRReactCurrentSession value
				callOn: 'Input'
				method: #'set_mouse_mode'
				arguments: {isMouseLocked get ifTrue: [2] ifFalse: [0]}]
		dependencies: {isMouseLocked get}.
	buttonCallback := self
		useCallback: [:pressed :button :position | isMouseLocked set: pressed]
		dependencies: {}.
	keyboardCallback := self
		useCallback: [:pressed :key :scanCode |
			key asCharacter = $w ifTrue: [moving set: (pressed ifTrue: [1] ifFalse: [0])].
			key asCharacter = $s ifTrue: [moving set: (pressed ifTrue: [-1] ifFalse: [0])]]
		dependencies: {}.
	mouseSub := self
		useCallback: [:delta |
			isMouseLocked get ifTrue: [ | pitch yaw |
				pitch := (delta y clampLow: -90 - totalPitch get high: 90 - totalPitch get) * self mouseSensitivity.
				yaw := delta x * self mouseSensitivity.
				
				totalPitch set: totalPitch get + pitch.
				transform set: [:t |
					(t rotatedGlobalBy: yaw around: 0 @ 1 @ 0)
						rotatedLocalBy: pitch
						around: 1 @ 0 @ 0]]]
		dependencies: {}.
	
	^ (self godot: #GREvents)
		children: {
			moving get ~= 0 ifTrue: [
				[ | timer |
					timer := self
						useCallback: [transform set: [:t | t localTranslatedBy: 0 @ 0 @ (-0.04 * moving get)]]
						dependencies: {}.
					(self godot: #Timer)
						autostart: true;
						wait_time: 0.01;
						timeout: timer] asComponent]};
		subscribeTo: #'relative_mouse_motion' do: mouseSub;
		button: buttonCallback;
		keyboard: keyboardCallback
]

{ #category : #'rendering - simulated' }
WorldDworph >> renderSimulated: props [

	| headTransform teleport worldRef |
	headTransform := self useState: (Matrix4x4 withOffset: 0 @ 1.7 @ 0).
	teleport := self useState: Matrix4x4 identity.
	worldRef := self useRef: nil.
	
	^ GRProvider
		values: {#headTransform -> headTransform get. #worldPortal -> worldRef. #teleport -> teleport}
		children: {
			(self godot: #Spatial) children: {
				(self methodAsComponent: #renderSimulatedController:)
					left: true;
					do: [:leftControllerNode |
						{
							(self methodAsComponent: #renderSimulatedController:)
								left: false;
								do: [:rightControllerNode |
									{
										(self godot: #Spatial)
											transform: teleport get;
											children: {
												(self methodAsComponent: #renderSimulatedControls:) headTransform: headTransform.
												(self godot: #Camera) transform: headTransform get.
												leftControllerNode.
												rightControllerNode.
												(self godot: #Spatial) ref: [:node | worldRef set: node]}, (props at: #children ifAbsent: [{}])}]}]}}
]

{ #category : #'rendering - simulated' }
WorldDworph >> renderSimulatedController: props [

	| transform handPortal handArea handIsFree pressedButtons controllerNode axes |
	transform := self useState: Matrix4x4 new.
	handIsFree := self useState: true.
	pressedButtons := self useState: {}.
	handPortal := self useRef: nil.
	handArea := self useRef: nil.
	
	axes := {{ControllerInfoDworph triggerAxis. #trigger}. {7. #grip}. {0. #'touchpad_x'}. {1. #'touchpad_y'}} collect: [:axis | | state |
		state := self useState: 0.0.
		axis, {state}].
	
	controllerNode := (self godot: #Spatial)
		transform: transform get;
		children: {
			(self godot: #Area)
				children: {
					(self godot: #CollisionShape) shape: ((self godot: #SphereShape)
						margin: 0.001;
						radius: 0.01)};
				ref: handArea.
			(self godot: #Spatial) ref: [:node | handPortal set: node].
			(self godot: #MeshInstance) mesh: ((self godot: #SphereMesh)
				radius: 0.01;
				height: 0.02;
				material: ((self godot: #SpatialMaterial) albedo_color: Color red))}.
	
	^ GRProvider
		namespace: ((props at: #left) == true ifTrue: [#left] ifFalse: [#right])
		values: {
			#controllerTransform -> transform get.
			#setControllerTransform -> transform.
			#handPortal -> handPortal.
			#handId -> handArea.
			#handIsFree -> handIsFree.
			#pressedButtons -> pressedButtons get.
			#setPressedButtons -> pressedButtons}, (axes gather: [:axis | {axis second -> axis third get. axis second, 'Set' -> axis third}])
		children: {(props at: #do) value: controllerNode}
]

{ #category : #'rendering - simulated' }
WorldDworph >> renderSimulatedControls: props [

	| controlling keySub |
	controlling := self useState: #headset.
	
	keySub := self
		useCallback: [:pressed :key :scanCode |
			scanCode = 'Control' ifTrue: [controlling set: (pressed ifTrue: [#left] ifFalse: [#headset])].
			scanCode = 'Alt' ifTrue: [controlling set: (pressed ifTrue: [#right] ifFalse: [#headset])]]
		dependencies: {}.
	
	^ {
		controlling get caseOf: {
			[#headset] -> [(self methodAsComponent: #renderFirstPersonControls:) transform: (props at: #headTransform)].
			[#left] -> [
				GRUseProviderNamespace
					namespace: #left
					children: {self methodAsComponent: #renderControllerControls:}].
			[#right] -> [
				GRUseProviderNamespace
					namespace: #right
					children: {self methodAsComponent: #renderControllerControls:}]}.
		(self godot: #GREvents) keyboard: keySub.
		(self methodAsComponent: #renderSimulatedHUD:) controlling: controlling get}
]

{ #category : #'rendering - simulated' }
WorldDworph >> renderSimulatedHUD: props [

	^ (self godot: #VBoxContainer) children: {(self godot: #Label) text: 'Controlling:'}, (#(#('Headset' #headset) #('Left Controller (Ctrl)' 'left') #('Right Controller (Alt)' 'right')) collect: [:pair |
		((self godot: #Label) text: pair first)
			call: #'add_color_override' arguments: {
				'font_color'.
				(props at: #controlling) = pair second
					ifTrue: [Color r: 1 g: 1 b: 1]
					ifFalse: [(Color r: 1 g: 1 b: 1) alpha: 0.7]};
			key: pair second])
]

{ #category : #'rendering - vr' }
WorldDworph >> renderVR: props [

	| headTransform headTransformSubscription worldRef teleport |
	self useVR.
	headTransform := self useState: Matrix4x4 identity.
	headTransformSubscription := self useCallback: [:t | headTransform set: t] dependencies: {}.
	teleport := self useState: Matrix4x4 identity.
	worldRef := self useRef: nil.
	
	^ GRProvider
		values: {#headTransform -> headTransform get. #worldPortal -> worldRef. #teleport -> teleport}
		children: {
			ControllerInfoDworph new
				left: true;
				do: [:leftControllerNode |
					{
						ControllerInfoDworph new
							left: false;
							do: [:rightControllerNode |
								{
									(self godot: #Spatial) children: {
										(self godot: #ARVROrigin)
											transform: teleport get;
											children: {
												(self godot: #ARVRCamera)
													subscribeTo: #'global_transform'
													do: headTransformSubscription.
												rightControllerNode.
												leftControllerNode}.
										(self godot: #Spatial) ref: [:node | worldRef set: node]}, (props at: #children ifAbsent: [{}])}]}]}
]

{ #category : #'rendering - vr' }
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

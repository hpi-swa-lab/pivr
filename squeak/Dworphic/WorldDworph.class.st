Class {
	#name : #WorldDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #'rendering - simulated' }
WorldDworph >> mouseSensitivity [

	^ 0.25
]

{ #category : #rendering }
WorldDworph >> render: props [

	^ (self methodAsComponent: #renderSimulated:) props: props
]

{ #category : #'rendering - simulated' }
WorldDworph >> renderControllerControls: props [

	| buttonCallback ref |
	ref := self useRef: nil.
	buttonCallback := self
		useCallback: [:pressed :button :position | | origin normal session state sceneTree viewport camera |
			session := GRReactCurrentSession value.
			sceneTree := session callOn: 'Engine' method: 'get_main_loop' arguments: {}.
			viewport := session get: 'root' of: sceneTree.
			camera := session callOn: viewport method: 'get_camera'.
			
			origin := session callOn: camera method: #'project_ray_origin' arguments: {position}.
			normal := (session callOn: camera method: #'project_ray_normal' arguments: {position}) * 100.
			
			state := session get: #'direct_space_state' of: (session callOn: ref get method: #'get_world').
			session callOn: state method: #'intersect_ray' arguments: {origin. normal}]
		dependencies: {}.
	
	^ (self godot: #Spatial)
		ref: ref;
		children: {(self godot: #GREvents) button: buttonCallback}
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
				ControllerInfoDworph new
					left: true;
					do: [:leftControllerNode |
						{
							ControllerInfoDworph new
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
			[#left] -> [self methodAsComponent: #renderControllerControls:].
			[#right] -> [self methodAsComponent: #renderControllerControls:]}.
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

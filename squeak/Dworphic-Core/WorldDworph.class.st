Class {
	#name : #WorldDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
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

	^ self
		useVRIfSupported: [(self methodAsComponent: #renderVR:) props: props]
		otherwise: [(self methodAsComponent: #renderSimulated:) props: props]
		loading: [nil]
]

{ #category : #'rendering - simulated' }
WorldDworph >> renderControllerControls: props [

	| buttonCallback ref controllerTransform keyboardCallback pressedButtons trigger |
	ref := self useRemoteRef.
	
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
		useCallback: [:pressed :scanCode :key |
			scanCode = GDGlobalConstants keySpace ifTrue: [
				pressed
					ifTrue: [pressedButtons set: [:b | b copyWith: ControllerInfoDworph grip]]
					ifFalse: [pressedButtons set: [:b | b copyWithout: ControllerInfoDworph grip]]].
			scanCode = GDGlobalConstants keyTab ifTrue: [pressed ifTrue: [trigger set: 1.0] ifFalse: [trigger set: 0.0]]]
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
			GDInput instance mouseMode: (isMouseLocked get
				ifTrue: [GDInput mouseModeCaptured]
				ifFalse: [GDInput mouseModeVisible])]
		dependencies: {isMouseLocked get}.
	buttonCallback := self
		useCallback: [:pressed :button :position | isMouseLocked set: pressed]
		dependencies: {}.
	keyboardCallback := self
		useCallback: [:pressed :scanCode :key |
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
					GDTimer new
						autostart: true;
						waitTime: 0.01;
						onTimeout: timer] asComponent]};
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
												(self godot: #Spatial) ref: worldRef}, (props at: #children ifAbsent: [{}])}]}]}}
]

{ #category : #'rendering - simulated' }
WorldDworph >> renderSimulatedController: props [

	| transform handPortal handArea handIsFree pressedButtons controllerNode axes |
	transform := self useState: Matrix4x4 new.
	handIsFree := self useState: true.
	pressedButtons := self useState: {}.
	handPortal := self useRef: nil.
	handArea := self useRemoteRef.
	
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
			(self godot: #Spatial) ref: handPortal.
			(self godot: #MeshInstance) mesh: ((self godot: #SphereMesh)
				radius: 0.01;
				height: 0.02;
				material: ((self godot: #SpatialMaterial) albedo_color: (Color r: 1 g: 0.0 b: 0.0)))}.
	
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
		useCallback: [:pressed :scanCode :key |
			scanCode = GDGlobalConstants keyControl ifTrue: [controlling set: (pressed ifTrue: [#left] ifFalse: [#headset])].
			scanCode = GDGlobalConstants keyAlt ifTrue: [controlling set: (pressed ifTrue: [#right] ifFalse: [#headset])]]
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
										(self godot: #Spatial) ref: worldRef}, (props at: #children ifAbsent: [{}])}]}]}
]

{ #category : #rendering }
WorldDworph >> useVRIfSupported: aBlock otherwise: anotherBlock loading: aThirdBlock [

	| supportsVR |
	supportsVR := self useState: nil.
	self
		useEffect: [ | openxr |
			openxr := GDARVRServer instance findInterfaceName: 'OpenXR'.
			openxr
				ifNotNil: [ | viewport |
					openxr initialize ifFalse: [self error: 'failed to initialize openxr'].
					viewport := (GD_Engine instance getMainLoop grAsClass: #GDSceneTree) root grAsClass: #GDViewport.
					GD_OS instance vsyncEnabled: true.
					GD_Engine instance iterationsPerSecond: 90.
					viewport hdr: true.
					viewport arvr: true.
					supportsVR set: true]
				ifNil: [supportsVR set: false]]
		dependencies: {}.
	
	supportsVR get == nil ifTrue: [^ aThirdBlock value].
	^ supportsVR get ifTrue: [aBlock value] ifFalse: [anotherBlock value]
]

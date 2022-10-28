Class {
	#name : #Avatar,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'rendering - vr' }
Avatar >> controllerIdForSide: side [

	^ side caseOf: {
		[#left] -> [1].
		[#right] -> [2]}
]

{ #category : #'rendering - vr' }
Avatar >> mirrorFactorForSide: side [

	^ side caseOf: {
		[#left] -> [-1].
		[#right] -> [1]}
]

{ #category : #'rendering - simulated' }
Avatar >> positionInSceneFor: aPoint spatialRef: aRef do: aBlock [

	| camera origin normal spatial |
	spatial := aRef get grAsClass: #GDSpatial.
	camera := (spatial getTree root grAsClass: #GDViewport) getCamera.
	origin := camera projectRayOriginScreenPoint: aPoint.
	normal := (camera projectRayNormalScreenPoint: aPoint) * 100.
	^ (spatial getWorld directSpaceState
		intersectRayFrom: origin
		to: normal
		exclude: {}
		collisionMask: 2147483647
		collideWithBodies: true
		collideWithAreas: true) ifNotEmpty: [:res | aBlock value: (res at: #position)]
]

{ #category : #rendering }
Avatar >> render: props [

	| vrSupported |
	vrSupported := self useState: nil.
	
	self
		useEffect: [
			(GDARVRServer instance findInterfaceName: 'OpenXR')
				ifNil: [vrSupported set: false]
				ifNotNil: [:openxr |
					openxr initialize.
					((GDEngine instance getMainLoop grAsClass: #GDSceneTree) root grAsClass: #GDViewport)
						hdr: true;
						arvr: true.
					GDEngine instance iterationsPerSecond: 90.
					GDOS instance vsyncEnabled: true.
					vrSupported set: true]]
		dependencies: {}.
	
	vrSupported get ifNil: [^ nil].
	
	^ vrSupported get
		ifTrue: [
			(GDARVROrigin new
				subscribeTo: #'global_transform'
				do: [:t | (props at: #setHead) value: t]) children: {
				GDARVRCamera new.
				(self methodAsComponent: #renderController:)
					side: #left;
					transform: (props at: #left);
					setTransform: (props at: #setLeft).
				(self methodAsComponent: #renderController:)
					side: #right;
					transform: (props at: #right);
					setTransform: (props at: #setRight)}]
		ifFalse: [
			(self methodAsComponent: #renderSimulated:)
				head: (props at: #head);
				setHead: (props at: #setHead);
				left: (props at: #left);
				setLeft: (props at: #setLeft);
				right: (props at: #right);
				setRight: (props at: #setRight)]
]

{ #category : #'rendering - vr' }
Avatar >> renderController: props [

	| controllerRef renderActiveHand handlers |
	
	controllerRef := self useRef: nil.
	handlers := self useRef: ({#onButtonPress -> [:x|]. #onButtonRelease -> [:x|]} as: Dictionary).
	renderActiveHand := self useRenderActiveHand.
	
	^ GDARVRController new
		ref: controllerRef;
		subscribeTo: #transform do: [:t | (props at: #setTransform) value: t];
		translation: (Vector3 value: 99999);
		controllerId: (self controllerIdForSide: (props at: #side));
		onButtonPressed: (handlers get at: #onButtonPress);
		onButtonRelease: (handlers get at: #onButtonRelease);
		children: {
			renderActiveHand value
				controllerRef: controllerRef;
				setHandlers: [:h | handlers set: h];
				side: (props at: #side);
				transform: (props at: #transform)}
]

{ #category : #'rendering - vr' }
Avatar >> renderHand: props [

	| handMesh areaRef |
	handMesh := self useHandMesh.
	
	areaRef := self useGodotRef.
	
	(props at: #setHandlers) value: (self
		useActiveEventHandlersFor: areaRef
		side: (props at: #side)
		transform: (props at: #transform)
		controller: (props at: #controllerRef)).
	
	^ GDSpatial new
		children: {
			GDMeshInstance new
				mesh: handMesh;
				scale: (self mirrorFactorForSide: (props at: #side)) @ 1 @ 1 * 0.25;
				translation: 0 @ -0.07 @ 0.1;
				rotation: -1.6 @ 0 @ 0.
			GDArea new
				ref: areaRef;
				children: {
					GDCollisionShape new
						shape: (GDSphereShape new radius: 0.05);
						translation: 0 @ -0.07 @ 0.05}}
]

{ #category : #'rendering - simulated' }
Avatar >> renderSimulated: props [

	| controlling |
	controlling := self useState: #headset.
	
	^ {
		OrbitCameraDworph new
			active: controlling get = #headset;
			transform: (props at: #head);
			setTransform: (props at: #setHead).
		GRExternalEvents new onKeyboard: [:pressed :scanCode :key |
			scanCode = GDGlobalConstants keyControl ifTrue: [controlling set: (pressed ifTrue: [#left] ifFalse: [#headset])].
			scanCode = GDGlobalConstants keyAlt ifTrue: [controlling set: (pressed ifTrue: [#right] ifFalse: [#headset])]].
		(self methodAsComponent: #renderSimulatedController:)
			side: #left;
			active: controlling get = #left;
			transform: (props at: #left);
			setTransform: (props at: #setLeft).
		(self methodAsComponent: #renderSimulatedController:)
			side: #right;
			active: controlling get = #right;
			transform: (props at: #right);
			setTransform: (props at: #setRight).
		(self methodAsComponent: #renderSimulatedHUD:) controlling: controlling get}
]

{ #category : #'rendering - simulated' }
Avatar >> renderSimulatedController: props [

	| handPortal handArea handIsFree pressedButtons axes handlers |
	handIsFree := self useState: true.
	pressedButtons := self useState: {}.
	handPortal := self useRef: nil.
	handArea := self useGodotRef.
	axes := {{ControllerInfoDworph triggerAxis. #trigger}. {7. #grip}. {0. #'touchpad_x'}. {1. #'touchpad_y'}} collect: [:axis | | state |
		state := self useState: 0.0.
		axis, {state}].
	
	handlers := self
		useActiveEventHandlersFor: handArea
		side: (props at: #side)
		transform: (props at: #transform)
		controller: handPortal.
	
	^ GDSpatial new
		transform: (props at: #transform);
		children: {
			GDArea new
				children: {
					GDCollisionShape new shape: (GDSphereShape new
						margin: 0.001;
						radius: 0.01)};
				ref: handArea.
			GDSpatial new ref: handPortal.
			GDMeshInstance new mesh: (GDSphereMesh new
				radius: 0.01;
				height: 0.02;
				material: (GDSpatialMaterial new albedoColor: (Color r: 1 g: 0.0 b: 0.0))).
			(props at: #active)
				ifTrue: [
					(self methodAsComponent: #renderSimulatedControllerControls:)
						setControllerTransform: (props at: #setTransform);
						handlers: handlers]
				ifFalse: [nil]}
]

{ #category : #'rendering - simulated' }
Avatar >> renderSimulatedControllerControls: props [

	| ref controllerTransform press release |
	controllerTransform := props at: #setControllerTransform.
	ref := self useGodotRef.
	press := (props at: #handlers) at: #onButtonPress.
	release := (props at: #handlers) at: #onButtonRelease.
	
	^ GDSpatial new
		ref: ref;
		children: {
			GRExternalEvents new
				onButton: [:pressed :button :position |
					self
						positionInSceneFor: position
						spatialRef: ref
						do: [:point | controllerTransform value: (Matrix4x4 withOffset: point)]];
				onKeyboard: [:pressed :scanCode :key | | cb |
					cb := pressed ifTrue: [press] ifFalse: [release].
					scanCode = GDGlobalConstants keySpace ifTrue: [cb value: GDGlobalConstants joyVrGrip].
					scanCode = GDGlobalConstants keyTab ifTrue: [cb value: GDGlobalConstants joyVrTrigger].
					
					(self directionFromScancode: scanCode) ifNotNil: [:dir | controllerTransform value: [:o | o translatedBy: dir * 0.03]]]}
]

{ #category : #'rendering - simulated' }
Avatar >> renderSimulatedHUD: props [

	^ GDVBoxContainer new children: {GDLabel new text: 'Controlling:'}, (#(#('Headset' #headset) #('Left Controller (Ctrl)' 'left') #('Right Controller (Alt)' 'right')) collect: [:pair |
		(GDLabel new text: pair first)
			call: #'add_color_override' arguments: {
				'font_color'.
				(props at: #controlling) = pair second
					ifTrue: [Color r: 1 g: 1 b: 1]
					ifFalse: [(Color r: 1 g: 1 b: 1) alpha: 0.7]};
			key: pair second])
]

{ #category : #'rendering - vr' }
Avatar >> useHandMesh [

	^ self
		useMemo: [GDResourceLoader instance loadPath: 'res://assets/models/hand/hand.tres']
		dependencies: #()
]

{ #category : #'rendering - vr' }
Avatar >> useRenderActiveHand [

	^ (self useProvided: #activeHand)
		ifNil: [self methodAsComponent: #renderHand:]
]

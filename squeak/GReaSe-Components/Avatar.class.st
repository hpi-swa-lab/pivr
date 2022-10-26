Class {
	#name : #Avatar,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
Avatar >> controllerIdForSide: side [

	^ side caseOf: {
		[#left] -> [1].
		[#right] -> [2]}
]

{ #category : #'as yet unclassified' }
Avatar >> grabButton [

	^ 2
]

{ #category : #'as yet unclassified' }
Avatar >> mirrorFactorForSide: side [

	^ side caseOf: {
		[#left] -> [-1].
		[#right] -> [1]}
]

{ #category : #'as yet unclassified' }
Avatar >> render: props [

	| avatarRoot |
	avatarRoot := self useGodotRef.
	
	self useEffect: [
		(GDARVRServer instance findInterfaceName: 'OpenXR')
			ifNil: [self error: 'Did not find OpenXR interface']
			ifNotNil: [:openxr |
				openxr initialize.
				avatarRoot get getViewport hdr: true; arvr: true.
				GDEngine instance iterationsPerSecond: 90.
				GDOS instance vsyncEnabled: true]] dependencies: {}.
	
	^ GDARVROrigin new
		ref: avatarRoot;
		children: {
			GDARVRCamera new.
			(self methodAsComponent: #renderHand:) side: #left.
			(self methodAsComponent: #renderHand:) side: #right}
]

{ #category : #'as yet unclassified' }
Avatar >> renderHand: props [

	| handMesh areaRef addHandAreaHandlers removeHandAreaHandlers controllerRef createInteractiveEvent activeEventHandlers createInteractiveButtonEvent transform |
	handMesh := self useHandMesh.
	
	controllerRef := self useRef: nil.
	areaRef := self useGodotRef.
	
	activeEventHandlers := self useState: OrderedCollection new.
	transform := self useRef: Matrix4x4 identity.
	
	addHandAreaHandlers := self useProvided: #addHandAreaHandlers.
	removeHandAreaHandlers := self useProvided: #removeHandAreaHandlers.
	
	createInteractiveEvent := [
		GRInteractiveAreaEvent new
			controllerRef: controllerRef;
			side: (props at: #side);
			transform: transform get].
	
	createInteractiveButtonEvent := [:button |
		(createInteractiveEvent value as: GRInteractiveAreaEventButton)
			button: button].
	
	self
		useEffect: [
			addHandAreaHandlers value: areaRef get value: (Dictionary withAll: {
				#onAreaEntered -> [:eventHandlers |
					"Transcript showln: 'interactable entered hand'."
					(eventHandlers at: #onHover) get ifNotNil: [:block |
						block cull: createInteractiveEvent value].
					activeEventHandlers set: [:old | old copyWith: eventHandlers]].
				#onAreaExited -> [:eventHandlers |
					"Transcript showln: 'interactable exited hand'."
					(eventHandlers at: #onBlur) get ifNotNil: [:block |
						block cull: createInteractiveEvent value].
					activeEventHandlers set: [:old | old copyWithout: eventHandlers]]}).
			[removeHandAreaHandlers value: areaRef get]]
		dependencies: #().
	
	^ GDARVRController new
		ref: controllerRef;
		subscribeTo: #transform do: [:t | transform set: t];
		translation: (Vector3 value: 99999);
		controllerId: (self controllerIdForSide: (props at: #side));
		onButtonPressed: [:button |
			activeEventHandlers get do: [:handlers |
				(handlers at: #onButtonPress) get ifNotNil: [:block |
					block cull: (createInteractiveButtonEvent value: button)]]];
		onButtonRelease: [:button |
			activeEventHandlers get do: [:handlers |
				(handlers at: #onButtonRelease) get ifNotNil: [:block |
					block cull: (createInteractiveButtonEvent value: button)]]];
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

{ #category : #'as yet unclassified' }
Avatar >> useHandMesh [

	^ self
		useMemo: [GDResourceLoader instance loadPath: 'res://assets/models/hand/hand.tres']
		dependencies: #()
]

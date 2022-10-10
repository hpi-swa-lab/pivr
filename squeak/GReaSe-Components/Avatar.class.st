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
	avatarRoot := self useRemoteRef.
	
	self useEffect: [
		(GDARVRServer instance findInterfaceName: 'OpenXR')
			ifNil: [self error: 'Did not find OpenXR interface']
			ifNotNil: [:openxr | | viewport |
				 openxr initialize.
				viewport := avatarRoot get getViewport.
				GD_Engine instance iterationsPerSecond: 90.
				viewport hdr: true.
				GD_OS instance vsyncEnabled: true.
				viewport arvr: true.].
		nil].

	^ GDARVROrigin new
		ref: avatarRoot;
		children: {
			GDARVRCamera new.
			(self methodAsComponent: #renderHand:)
				side: #left.
			(self methodAsComponent: #renderHand:)
				side: #right}
]

{ #category : #'as yet unclassified' }
Avatar >> renderHand: props [

	| handMesh areaRef addHandArea removeHandArea getGrabReleaseCallbacks |
	handMesh := self useMemo: [GD_ResourceLoader instance loadPath: 'res://assets/models/hand/hand.tres']
		dependencies: #().
	
	areaRef := self useRemoteRef.
	addHandArea := self useProvided: #addHandArea.
	removeHandArea := self useProvided: #removeHandArea.
	getGrabReleaseCallbacks := self useProvided: #getGrabReleaseCallbacks.
	
	self useEffect: [
		addHandArea value: areaRef get.
		[removeHandArea value: areaRef get]] dependencies: #().

	^ GDARVRController new
		"This initial translation prevents the hand area overlapping with other areas before its translation is synchronized with VR"
		translation: (Vector3 value: 99999);
		controllerId: (self controllerIdForSide: (props at: #side));
		onButtonPressed: [:button | button = self grabButton ifTrue: [
				Transcript showln: getGrabReleaseCallbacks value.
				getGrabReleaseCallbacks value do: [:callbacks |
					(callbacks at: #onGrab) ifNotNil: [:block | block value: nil]]]];
		onButtonRelease: [:button | button = self grabButton ifTrue: [
				getGrabReleaseCallbacks value do: [:callbacks |
					(callbacks at: #onRelease) ifNotNil: [:block | block value: nil]]]];
		children: {
			GDMeshInstance new
				mesh: handMesh;
				scale: ((self mirrorFactorForSide: (props at: #side)) @ 1 @ 1) * 0.25;
				translation: 0 @ -0.07 @ 0.1;
				rotation: -1.6 @ 0 @ 0.
			GDArea new
				ref: areaRef;
				children: {
					GDCollisionShape new
						shape: (GDSphereShape new
							radius: 0.05);
						translation: 0 @ -0.07 @ 0.05}}
]

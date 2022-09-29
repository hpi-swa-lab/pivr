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
Avatar >> mirrorFactorForSide: side [

	^ side caseOf: {
		[#left] -> [-1].
		[#right] -> [1]}
]

{ #category : #'as yet unclassified' }
Avatar >> render: props [

	| avatarRoot |
	avatarRoot := self useRef: nil.
	
	self useEffect: [ | viewport session |
		session := GRReactCurrentSession value.
		(session
			callOn: 'ARVRServer'
			method: 'find_interface'
			arguments: {'OpenXR'})
			ifNil: [self error: 'Did not find OpenXR interface']
			ifNotNil: [:openxr |
				session
					callOn: openxr
					method: 'initialize'.
				viewport := session
					callOn: avatarRoot get
					method: 'get_viewport'.
				session set: 'iterations_per_second' of: 'Engine' to: 90.
				session set: 'hdr' of: viewport to: false.
				session set: 'vsync_enabled' of: 'OS' to: true.
				session set: 'arvr' of: viewport to: true.].
		nil].

	^ (self godot: #ARVROrigin)
		ref: avatarRoot;
		children: {
			(self godot: #ARVRCamera).
			(self methodAsComponent: #renderHand:)
				side: #left.
			(self methodAsComponent: #renderHand:)
				side: #right}
]

{ #category : #'as yet unclassified' }
Avatar >> renderHand: props [

	| handMesh mirrorFactor |
	handMesh := self useMemo: [
		GRReactCurrentSession value
			callOn: 'ResourceLoader'
			method: 'load'
			arguments: {'res://assets/models/hand/hand.tres'}]
		dependencies: #().
	
	mirrorFactor := self mirrorFactorForSide: (props at: #side).

	^ (self godot: #ARVRController)
		controller_id: (self controllerIdForSide: (props at: #side));
		children: {
			(self godot: #MeshInstance)
				mesh: handMesh;
				scale: (mirrorFactor @ 1 @ 1) * 0.25;
				translation: 0 @ -0.07 @ 0.1;
				rotation: -1.6 @ 0 @ 0.
			(self godot: #Area)
				children: {
					(self godot: #CollisionShape)
						shape: ((self godot: #SphereShape)
							radius: 0.1)}}
]

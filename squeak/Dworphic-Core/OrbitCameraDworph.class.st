Class {
	#name : #OrbitCameraDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
OrbitCameraDworph >> mouseSensitivity [

	^ 0.25
]

{ #category : #'as yet unclassified' }
OrbitCameraDworph >> render: props [

	| transform totalPitch isMouseLocked moving |
	transform := self useState: (props at: #transform ifAbsent: [Matrix4x4 identity]).
	
	isMouseLocked := self useState: false.
	moving := self useState: 0.
	totalPitch := self useRef: 0.
	
	self
		useEffect: [
			GDInput instance mouseMode: (isMouseLocked get
				ifTrue: [GDInput mouseModeCaptured]
				ifFalse: [GDInput mouseModeVisible])]
		dependencies: {isMouseLocked get}.
	
	^ GRExternalEvents new
		children: {
			moving get ~= 0 ifTrue: [
				[ | timer |
					timer := self
						useCallback: [transform set: [:t | t localTranslatedBy: 0 @ 0 @ (-0.04 * moving get)]]
						dependencies: {}.
					GDTimer new
						autostart: true;
						waitTime: 0.01;
						onTimeout: timer] asComponent].
			GDCamera new transform: transform get};
		subscribeToRelativeMouseMotion: [:delta |
			isMouseLocked get ifTrue: [ | pitch yaw |
				pitch := (delta y clampLow: -90 - totalPitch get high: 90 - totalPitch get) * self mouseSensitivity.
				yaw := delta x * self mouseSensitivity.
				totalPitch set: totalPitch get + pitch.
				transform set: [:t |
					(t rotatedGlobalBy: yaw around: 0 @ 1 @ 0)
						rotatedLocalBy: pitch
						around: 1 @ 0 @ 0]]];
		onButton: [:pressed :button :position | isMouseLocked set: pressed];
		onKeyboard: [:pressed :scanCode :key |
			scanCode = GDGlobalConstants keyW ifTrue: [moving set: (pressed ifTrue: [1] ifFalse: [0])].
			scanCode = GDGlobalConstants keyS ifTrue: [moving set: (pressed ifTrue: [-1] ifFalse: [0])]]
]

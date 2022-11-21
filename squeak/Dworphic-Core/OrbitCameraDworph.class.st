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

	| transform totalPitch isMouseLocked moving mouseMoving nonControlledTransform setTransform active invertedFactor |
	nonControlledTransform := self useState: Matrix4x4 identity.
	transform := props at: #transform ifAbsent: [nonControlledTransform get].
	setTransform := props at: #setTransform ifAbsent: [nonControlledTransform setter].
	
	isMouseLocked := self useState: false.
	moving := self useState: 0 @ 0 @ 0.
	totalPitch := self useRef: 0.
	
	active := props at: #active ifAbsent: [true].
	mouseMoving := isMouseLocked get and: [active].
	
	invertedFactor := (props at: #inverted ifAbsent: [false])
		ifTrue: [-1]
		ifFalse: [1].
	
	self
		useEffect: [GDInput instance mouseMode: (mouseMoving ifTrue: [GDInput mouseModeCaptured] ifFalse: [GDInput mouseModeVisible])]
		dependencies: {mouseMoving}.
	
	^ GRExternalEvents new
		children: {
			moving get isZero ifFalse: [
				[ | timer |
					timer := self
						useCallback: [setTransform value: [:t | t localTranslatedBy: moving get * 0.07]]
						dependencies: {}.
					GDTimer new
						autostart: true;
						waitTime: 0.01;
						onTimeout: timer] asComponent].
			GDCamera new transform: transform};
		subscribeToRelativeMouseMotion: [:delta |
			mouseMoving ifTrue: [ | pitch yaw |
				pitch := (delta y clampLow: -90 - totalPitch get high: 90 - totalPitch get) * self mouseSensitivity.
				yaw := delta x * self mouseSensitivity.
				totalPitch set: totalPitch get + pitch.
				setTransform value: [:t |
					(t rotatedGlobalBy: invertedFactor * yaw around: 0 @ 1 @ 0)
						rotatedLocalBy: invertedFactor * pitch
						around: 1 @ 0 @ 0]]];
		onButton: [:pressed :button :position | isMouseLocked set: pressed];
		onKeyboard: [:pressed :scanCode :key | | dir |
			dir := self directionFromScancode: scanCode.
			(dir notNil and: [active]) ifTrue: [moving set: (pressed ifTrue: [dir] ifFalse: [0 @ 0 @ 0])]]
]

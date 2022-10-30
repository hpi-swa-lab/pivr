Class {
	#name : #GRGrabbableArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRGrabbableArea >> render: props [

	^ props extract: [:transform :rest | | handRef currentTransform isGrabbed inPlaceRef |
		handRef := self useState: nil.
		inPlaceRef := self useRef: nil.
		isGrabbed := handRef get notNil.
		
		currentTransform := self useState: Matrix4x4 identity.
		
		^ GDSpatial new
			ref: inPlaceRef;
			children: (CMFReactNodePortal
				child: {
					(self methodAsComponent: #renderArea:)
						props: rest;
						isGrabbed: handRef get notNil;
						transform: (isGrabbed ifTrue: [Matrix4x4 identity] ifFalse: [transform ifNil: [currentTransform get]]);
						getHandRef: [handRef get];
						setHandRef: [:ref | handRef set: ref];
						setTransform: [:t | currentTransform set: t]}
				in: (handRef get ifNil: [inPlaceRef]))]
]

{ #category : #'as yet unclassified' }
GRGrabbableArea >> renderArea: props [

	^ props extract: [:setHandRef :setTransform :onGrab :onRelease :onHover :onBlur :onButtonPress :onButtonRelease :children :isGrabbed :rest |
		GRInteractiveArea new
			props: rest;
			touch: true;
			onHover: (onHover ifNil: [[]]);
			onBlur: (onBlur ifNil: [[]]);
			onButtonPress: [:event |
				event isGrip ifTrue: [
					event
						acquireGrab: [
							setHandRef value: event controllerRef.
							onGrab ifNotNil: [:block | block cull: event]]
						ifBlocked: []].
				onButtonPress ifNotNil: [:block | block cull: event]];
			onButtonRelease: [:event |
				event isGrip ifTrue: [
					event releaseGrab.
					setHandRef value: nil.
					onRelease ifNotNil: [:block | block cull: event].
					setTransform value: event transform].
				onButtonRelease ifNotNil: [:block | block cull: event]];
			children: children]
]

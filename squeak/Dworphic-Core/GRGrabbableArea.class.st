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
						transform: (isGrabbed ifTrue: [Matrix4x4 identity] ifFalse: [transform ifNil: [currentTransform get]]);
						getHandRef: [handRef get];
						setHandRef: [:ref | handRef set: ref];
						setTransform: [:t | currentTransform set: t]}
				in: (handRef get ifNil: [inPlaceRef]))]
]

{ #category : #'as yet unclassified' }
GRGrabbableArea >> renderArea: props [

	^ props extract: [:setHandRef :setTransform :onGrab :onRelease :onHover :onBlur :onButtonPress :onButtonRelease :children :rest |
		GRInteractiveArea new
			props: rest;
			onHover: onHover;
			onBlur: onBlur;
			onButtonPress: [:event |
				event isGrip ifTrue: [
					event
						acquireGrab: [
							setHandRef value: event controllerRef.
							onGrab ifNotNil: [:block | block cull: event]]
						ifBlocked: []].
				onButtonPress ifNotNil: [:block | block cull: event]];
			onButtonRelease: [:event |
				event isGrip ifTrue: [ | transform |
					event releaseGrab.
					setHandRef value: nil.
					transform := onRelease ifNotNil: [:block | block cull: event].
					setTransform value: (transform class = Matrix4x4 ifTrue: [transform] ifFalse: [event transform])].
				onButtonRelease ifNotNil: [:block | block cull: event]];
			children: children]
]

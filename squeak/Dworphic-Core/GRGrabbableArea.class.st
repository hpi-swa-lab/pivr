Class {
	#name : #GRGrabbableArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRGrabbableArea >> render: props [

	| handRef transform isGrabbed inPlaceRef |
	handRef := self useState: nil.
	inPlaceRef := self useRef: nil.
	isGrabbed := handRef get notNil.
	
	transform := self useState: Matrix4x4 identity.
	
	^ GDSpatial new
		ref: inPlaceRef;
		children: (CMFReactNodePortal
			child: {
				(self methodAsComponent: #renderArea:)
					props: props;
					transform: (isGrabbed
						ifTrue: [Matrix4x4 identity]
						ifFalse: [props at: #transform ifAbsent: [transform get]]);
					getHandRef: [handRef get];
					setHandRef: [:ref | handRef set: ref];
					setTransform: [:t | transform set: t]}
			in: (handRef get ifNil: [inPlaceRef]))
]

{ #category : #'as yet unclassified' }
GRGrabbableArea >> renderArea: props [

	^ GRInteractiveArea new
		props: props copy;
		onHover: (props at: #onHover ifAbsent: [nil]);
		onBlur: (props at: #onBlur ifAbsent: [nil]);
		onButtonPress: [:event |
			event isGrip ifTrue: [
				event
					acquireGrab: [
						(props at: #setHandRef) value: event controllerRef.
						props at: #onGrab ifPresent: [:block | block cull: event]]
					ifBlocked: []].
			props at: #onButtonPress ifPresent: [:block | block cull: event]];
		onButtonRelease: [:event |
			event isGrip ifTrue: [ | transform |
				event releaseGrab.
				(props at: #setHandRef) value: nil.
				transform := props at: #onRelease ifPresent: [:block | block cull: event].
				(props at: #setTransform) value: (transform class = Matrix4x4 ifTrue: [transform] ifFalse: [event transform])].
			props at: #onButtonRelease ifPresent: [:block | block cull: event]];
		children: (props at: #children)
]

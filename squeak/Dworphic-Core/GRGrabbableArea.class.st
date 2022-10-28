Class {
	#name : #GRGrabbableArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRGrabbableArea >> render: props [

	| handRef component transform isGrabbed |
	handRef := self useState: nil.
	isGrabbed := handRef get notNil.
	
	component := isGrabbed
		ifTrue: [self methodAsComponent: #renderGrabbed:]
		ifFalse: [self methodAsComponent: #renderUngrabbed:].
	
	transform := self useState: Matrix4x4 identity.
	
	^ component
		props: props;
		transform: (isGrabbed
			ifTrue: [Matrix4x4 identity]
			ifFalse: [props at: #transform ifAbsent: [transform get]]);
		getHandRef: [handRef get];
		setHandRef: [:ref | handRef set: ref];
		setTransform: [:t | transform set: t]
]

{ #category : #'as yet unclassified' }
GRGrabbableArea >> renderArea: props [

	^ GRInteractiveArea new
		props: props copy;
		onHover: (props at: #onHover ifAbsent: [nil]);
		onBlur: (props at: #onBlur ifAbsent: [nil]);
		onButtonPress: [:event |
			event isGrip ifTrue: [
				(props at: #setHandRef) value: event controllerRef.
				props at: #onGrab ifPresent: [:block | block cull: event]].
			props at: #onButtonPress ifPresent: [:block | block cull: event]];
		onButtonRelease: [:event |
			event isGrip ifTrue: [ | transform |
				(props at: #setHandRef) value: nil.
				transform := props at: #onRelease ifPresent: [:block | block cull: event].
				(props at: #setTransform) value: (transform class = Matrix4x4 ifTrue: [transform] ifFalse: [event transform])].
			props at: #onButtonRelease ifPresent: [:block | block cull: event]];
		children: (props at: #children)
]

{ #category : #'as yet unclassified' }
GRGrabbableArea >> renderGrabbed: props [

	^ CMFReactNodePortal
		child: {self renderArea: props}
		in: (props at: #getHandRef) value
]

{ #category : #'as yet unclassified' }
GRGrabbableArea >> renderUngrabbed: props [

	^ self renderArea: props
]

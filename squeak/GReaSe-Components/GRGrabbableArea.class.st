Class {
	#name : #GRGrabbableArea,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GRGrabbableArea >> render: props [

	| handRef component translation isGrabbed |
	handRef := self useState: nil.
	isGrabbed := handRef get notNil.
	
	component := isGrabbed
		ifTrue: [self methodAsComponent: #renderGrabbed:]
		ifFalse: [self methodAsComponent: #renderUngrabbed:].
		
	translation := self useState: Vector3 zero.

	^ component
		props: props;
		translation: (isGrabbed
			ifTrue: [Vector3 zero]
			ifFalse: [props at: #translation ifAbsent: [translation get]]);
		getHandRef: [handRef get];
		setHandRef: [:ref | handRef set: ref];
		setTranslation: [:t | translation set: t]
]

{ #category : #'as yet unclassified' }
GRGrabbableArea >> renderArea: props [

	^ GRInteractiveArea new
		"props: props;"
		translation: (props at: #translation);
		onHover: (props at: #onHover);
		onBlur: (props at: #onBlur);
		onButtonPress: [:event |
			Transcript showln: 'press button'.
			event button = 2 ifTrue: [
				Transcript showln: 'grab thing'.
				(props at: #setHandRef) value: event controllerRef.
				props at: #onGrab ifPresent: [:block | block cull: event]].
			props at: #onButtonPress ifPresent: [:block | block cull: event]];
		onButtonRelease: [:event |
			Transcript showln: 'release button'.
			event button = 2 ifTrue: [ 
				Transcript showln: 'release thing'.
				(props at: #setTranslation) value: event transform translation.
				Transcript showln: 'setting translation ', event transform translation.
				(props at: #setHandRef) value: nil.
				props at: #onRelease ifPresent: [:block | block cull: event]].
			props at: #onButtonPress ifPresent: [:block | block cull: event]];
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

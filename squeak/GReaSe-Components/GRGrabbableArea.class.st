Class {
	#name : #GRGrabbableArea,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GRGrabbableArea >> render: props [

	| handRef component |
	handRef := self useState: nil.
	component := handRef get
		ifNil: [self methodAsComponent: #renderUngrabbed:]
		ifNotNil: [self methodAsComponent: #renderGrabbed:].

	^ component
		props: props;
		getHandRef: [handRef get];
		setHandRef: [:ref | handRef set: ref]
]

{ #category : #'as yet unclassified' }
GRGrabbableArea >> renderArea: props [

	^ GRInteractiveArea new
		"props: props;"
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
				Transcript showln: 'xxxxxxxx ', (GRReactCurrentSession value
					callOn: event controllerRef get fourth
					method: 'get'
					arguments: {'translation'}).
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

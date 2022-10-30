Class {
	#name : #GRInteractiveArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRInteractiveArea class >> pointLayer [

	^ 1 bitShift: 31
]

{ #category : #'as yet unclassified' }
GRInteractiveArea class >> touchLayer [

	^ 1 bitShift: 30
]

{ #category : #'as yet unclassified' }
GRInteractiveArea >> render: props [

	| handleAreaEnteredInteractable handleAreaExitedInteractable eventHandlers |
	^ props extract: [:children :onHover :onBlur :onButtonPress :onButtonRelease :rest :touch :point |
		handleAreaEnteredInteractable := self useProvided: #handleAreaEnteredInteractable.
		handleAreaExitedInteractable := self useProvided: #handleAreaExitedInteractable.
		eventHandlers := self useRef: Dictionary new.
		#(#onHover #onBlur #onButtonPress #onButtonRelease) do: [:event | eventHandlers get at: event put: (props at: event ifAbsent: [nil])].
		GDArea new
			setAll: rest;
			collisionMask: 0;
			collisionLayer: (((touch ifNil: [true]) ifTrue: [self class touchLayer] ifFalse: [0]) bitOr: ((point ifNil: [false]) ifTrue: [self class pointLayer] ifFalse: [0]));
			onAreaEntered: [:node | handleAreaEnteredInteractable value: node value: eventHandlers get];
			onAreaExited: [:node | handleAreaExitedInteractable value: node value: eventHandlers get];
			children: children]
]

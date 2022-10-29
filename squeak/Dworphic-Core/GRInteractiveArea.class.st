Class {
	#name : #GRInteractiveArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRInteractiveArea >> render: props [

	| handleAreaEnteredInteractable handleAreaExitedInteractable eventHandlers |
	handleAreaEnteredInteractable := self useProvided: #handleAreaEnteredInteractable.
	handleAreaExitedInteractable := self useProvided: #handleAreaExitedInteractable.
	eventHandlers := self useRef: Dictionary new.
	#(#onHover #onBlur #onButtonPress #onButtonRelease) do: [:event | eventHandlers get at: event put: (props at: event ifAbsent: [nil])].
	^ GDArea new
		setAll: props;
		meta: #isInteractive set: true;
		onAreaEntered: [:node | handleAreaEnteredInteractable value: node value: eventHandlers get];
		onAreaExited: [:node | handleAreaExitedInteractable value: node value: eventHandlers get];
		children: (props at: #children)
]

Class {
	#name : #GRInteractiveArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRInteractiveArea >> render: props [

	| handleAreaEnteredInteractable handleAreaExitedInteractable eventHandlers activeAreas |
	handleAreaEnteredInteractable := self useProvided: #handleAreaEnteredInteractable.
	handleAreaExitedInteractable := self useProvided: #handleAreaExitedInteractable.
	eventHandlers := self useRef: Dictionary new.
	#(#onHover #onBlur #onButtonPress #onButtonRelease) do: [:event | eventHandlers get at: event put: (props at: event ifAbsent: [nil])].
	activeAreas := self useRef: {}.
	
	self
		useEffect: [[activeAreas get do: [:node | handleAreaExitedInteractable value: node value: eventHandlers get]]]
		dependencies: {}.
	
	^ GDArea new
		setAll: props;
		meta: #isInteractive set: true;
		onAreaEntered: [:node |
			handleAreaEnteredInteractable value: node value: eventHandlers get.
			activeAreas set: (activeAreas get copyWith: node)];
		onAreaExited: [:node |
			handleAreaExitedInteractable value: node value: eventHandlers get.
			activeAreas set: (activeAreas get copyRemove: node)];
		children: (props at: #children)
]

Class {
	#name : #GRInteractiveArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRInteractiveArea >> render: props [

	| handleAreaEnteredInteractable handleAreaExitedInteractable eventHandlers interactionTypes |
	handleAreaEnteredInteractable := self useProvided: #handleAreaEnteredInteractable.
	handleAreaExitedInteractable := self useProvided: #handleAreaExitedInteractable.
	interactionTypes := #(touch point) select: [:symbol | props at: symbol ifAbsent: [false]].
	eventHandlers := self useRef: Dictionary new.
	#(#onHover #onBlur #onButtonPress #onButtonRelease) do: [:symbol |
		eventHandlers get at: symbol put: [:event |
			(interactionTypes includes: event type)
				ifTrue: [props at: symbol ifPresent: [:block | block cull: event]];
				yourself]].
	^ GDArea new
		setAll: props;
		meta: #allowsPointing set: (interactionTypes includes: #point);
		onAreaEntered: [:node | handleAreaEnteredInteractable value: node value: eventHandlers get];
		onAreaExited: [:node | handleAreaExitedInteractable value: node value: eventHandlers get];
		children: (props at: #children)
]

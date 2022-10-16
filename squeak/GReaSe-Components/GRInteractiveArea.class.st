Class {
	#name : #GRInteractiveArea,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GRInteractiveArea >> render: props [

	| handleAreaEnteredInteractable handleAreaExitedInteractable eventHandlers |
	handleAreaEnteredInteractable := self useProvided: #handleAreaEnteredInteractable.
	handleAreaExitedInteractable := self useProvided: #handleAreaExitedInteractable.
	eventHandlers := #(onHover onBlur onGrab onRelease)
		collect: [:symbol | | ref |
			ref := self useRef: nil.
			ref set: (props at: symbol).
			symbol -> ref]
		as: Dictionary.

	^ GDArea new
		onAreaEntered: [:node |
			handleAreaEnteredInteractable value: node value: eventHandlers.];
		onAreaExited: [:node |
			handleAreaExitedInteractable value: node value: eventHandlers];
		children: (props at: #children)
]

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
	eventHandlers := #(onHover onBlur onButtonPress onButtonRelease)
		collect: [:symbol | | ref |
			ref := self useRef: nil.
			props at: symbol ifPresent: [:handler | ref set: handler].
			symbol -> ref]
		as: Dictionary.
	
	^ GDArea
		setAll: props;
		onAreaEntered: [:node |
			handleAreaEnteredInteractable value: node value: eventHandlers];
		onAreaExited: [:node |
			handleAreaExitedInteractable value: node value: eventHandlers];
		children: (props at: #children)
]

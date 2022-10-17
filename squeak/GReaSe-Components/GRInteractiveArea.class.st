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
			ref set: (props at: symbol).
			symbol -> ref]
		as: Dictionary.

	^ GDArea new
		"extracting these godot specific props from the dict is a temp solution"
		translation: (props at: #translation ifAbsent: [Vector3 value: 0]);
		scale: (props at: #scale ifAbsent: [Vector3 value: 1]);
		onAreaEntered: [:node |
			handleAreaEnteredInteractable value: node value: eventHandlers.];
		onAreaExited: [:node |
			handleAreaExitedInteractable value: node value: eventHandlers];
		children: (props at: #children)
]

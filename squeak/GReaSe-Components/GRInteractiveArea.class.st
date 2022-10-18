Class {
	#name : #GRInteractiveArea,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GRInteractiveArea >> render: props [

	| handleAreaEnteredInteractable handleAreaExitedInteractable eventHandlers area |
	handleAreaEnteredInteractable := self useProvided: #handleAreaEnteredInteractable.
	handleAreaExitedInteractable := self useProvided: #handleAreaExitedInteractable.
	eventHandlers := #(onHover onBlur onButtonPress onButtonRelease)
		collect: [:symbol | | ref |
			ref := self useRef: nil.
			ref set: (props at: symbol).
			symbol -> ref]
		as: Dictionary.

	area := GDArea new.
	"TODO: settings props should be directly supported on GDArea and such"
	props keysAndValuesDo: [:key :value | key = #children ifFalse: [area set: key to: value]].
	area
		onAreaEntered: [:node |
			handleAreaEnteredInteractable value: node value: eventHandlers.];
		onAreaExited: [:node |
			handleAreaExitedInteractable value: node value: eventHandlers];
		children: (props at: #children).
	
	^ area
]

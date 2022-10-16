Class {
	#name : #GRAlternativeWorld,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GRAlternativeWorld >> render: props [

	| handAreaHandlers |
	handAreaHandlers := self useState: Dictionary new.

	^ GRProvider
		values: {
			#addHandAreaHandlers -> [:area :handlers |
				handAreaHandlers set: [:old | old copyWith: area -> handlers]].
			#removeHandAreaHandlers -> [:area |
				handAreaHandlers set: [:old | old copyWithoutKey: area]].
			#handleAreaEnteredInteractable -> [:area :eventHandlers |
				handAreaHandlers get at: area ifPresent: [:handHandlers |
					(handHandlers at: #onAreaEntered) value: eventHandlers]].
			#handleAreaExitedInteractable -> [:area :eventHandlers |
				handAreaHandlers get at: area ifPresent: [:handHandlers |
					(handHandlers at: #onAreaExited) value: eventHandlers]].}
		children: {
			GDSpatial new
				children: (props at: #children)}
]

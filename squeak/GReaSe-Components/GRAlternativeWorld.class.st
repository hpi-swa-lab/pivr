Class {
	#name : #GRAlternativeWorld,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GRAlternativeWorld >> render: props [

	| handAreaHandlers |
	"handAreas := self useState: OrderedCollection new.
	grabReleaseCallbacks := self useState: OrderedCollection new."
	handAreaHandlers := self useState: Dictionary new.

	^ GRProvider
		values: {
			#addHandAreaHandlers -> [:area :handlers |
				handAreaHandlers set: (handAreaHandlers get copyWith: area -> handlers)].
			#removeHandAreaHandlers -> [:area |
				handAreaHandlers set: (handAreaHandlers get copyWithoutKey: area)].
			#handleAreaEnteredInteractable -> [:area :eventHandlers |
				handAreaHandlers get at: area ifPresent: [:handHandlers |
					(handHandlers at: #onAreaEntered) value: eventHandlers]].
			#handleAreaExitedInteractable -> [:area :eventHandlers |
				handAreaHandlers get at: area ifPresent: [:handHandlers |
					(handHandlers at: #onAreaExited) value: eventHandlers]].
			"#addHandArea -> [:area | Transcript showln: 'add'.handAreas set: (handAreas get copyWith: area)].
			#removeHandArea -> [:area | Transcript showln: 'remove'.handAreas set: (handAreas get copyWithout: area)].
			#getHandAreas -> [handAreas get].
			#addGrabReleaseCallbacks -> [:callbacks |
				grabReleaseCallbacks set: (grabReleaseCallbacks get copyWith: callbacks)].
			#removeGrabReleaseCallbacks -> [:callbacks|
				grabReleaseCallbacks set: (grabReleaseCallbacks get copyWithout: callbacks)].
			#getGrabReleaseCallbacks -> [grabReleaseCallbacks get]"}
		children: {
			GDSpatial new
				children: (props at: #children)}
]

Class {
	#name : #AlternativeWorldDworph,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
AlternativeWorldDworph >> render: props [

	| handAreaHandlers apps |
	handAreaHandlers := self useState: Dictionary new.
	apps := self useState: OrderedCollection new.

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
					(handHandlers at: #onAreaExited) value: eventHandlers]].
			#openApplication -> [:appClass :config |
				apps set: [:old |
					old copyWith: (DworphicApplicationInfo new
						appClass: appClass;
						config: config)]]}
		children: {
			GDSpatial new
				children: (props at: #children), (apps get collect: [:info | info buildComponent])}
]

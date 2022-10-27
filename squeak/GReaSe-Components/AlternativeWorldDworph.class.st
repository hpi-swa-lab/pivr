Class {
	#name : #AlternativeWorldDworph,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
AlternativeWorldDworph >> render: props [

	| handAreaHandlers apps worldPortalRef |
	handAreaHandlers := self useState: Dictionary new.
	apps := self useState: OrderedCollection new.
	worldPortalRef := self useRef: nil.
	
	^ GRProvider
		values: {
			#addHandAreaHandlers -> [:area :handlers | handAreaHandlers set: [:old | old copyWith: area -> handlers]].
			#removeHandAreaHandlers -> [:area | handAreaHandlers set: [:old | old copyWithoutKey: area]].
			#handleAreaEnteredInteractable -> [:area :eventHandlers |
				handAreaHandlers get
					at: area
					ifPresent: [:handHandlers | (handHandlers at: #onAreaEntered) value: eventHandlers]].
			#handleAreaExitedInteractable -> [:area :eventHandlers |
				handAreaHandlers get
					at: area
					ifPresent: [:handHandlers | (handHandlers at: #onAreaExited) value: eventHandlers]].
			#openApplication -> [:appDescription |
				apps set: [:old | old copyWith: appDescription].
				appDescription id].
			#closeApplication -> [:id | apps set: [:old | old reject: [:appDescription | appDescription id = id]]].
			#applications -> apps get.
			#worldPortal -> worldPortalRef.
			#activeHand -> ((apps get select: #hasHandComponent)
				ifEmpty: [nil]
				ifNotEmpty: [:handApps | (handApps detectMax: #priority) handComponent])}
		children: {
			GDSpatial new children: (props at: #children), (apps get collect: [:info | info buildComponent key: info id]), {GDSpatial new ref: worldPortalRef}}
]

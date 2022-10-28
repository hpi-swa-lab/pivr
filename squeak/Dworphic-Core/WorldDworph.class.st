Class {
	#name : #WorldDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
WorldDworph >> render: props [

	| handAreaHandlers apps worldPortalRef head left right |
	handAreaHandlers := self useState: Dictionary new.
	apps := self useState: OrderedCollection new.
	head := self useState: Matrix4x4 identity.
	left := self useState: Matrix4x4 identity.
	right := self useState: Matrix4x4 identity.
	
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
				appDescription].
			#closeApplication -> [:appDescription | apps set: [:old | old copyWithout: appDescription]].
			#applications -> apps get.
			#worldPortal -> worldPortalRef.
			#headTransform -> head get.
			#activeHand -> ((apps get select: #hasHandComponent)
				ifEmpty: [nil]
				ifNotEmpty: [:handApps | (handApps detectMax: #priority) handComponent])}
		children: {
			Avatar new
				left: left get;
				right: right get;
				head: head get;
				setLeft: left setter;
				setRight: right setter;
				setHead: head setter.
			GDSpatial new children: (props at: #children), (apps get collect: [:appDescription | appDescription buildComponent key: appDescription]), {GDSpatial new ref: worldPortalRef}}
]

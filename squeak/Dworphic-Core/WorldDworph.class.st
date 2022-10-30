Class {
	#name : #WorldDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #rendering }
WorldDworph >> provideAreaHandlers [
	<provider>

	| buttonHandlers handAreaHandlers |
	buttonHandlers := self useRef: (Dictionary withAll: {#left -> OrderedCollection new. #right -> OrderedCollection new}).
	handAreaHandlers := self useState: Dictionary new.
	
	^ {
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
		#buttonHandlers -> buttonHandlers}
]

{ #category : #rendering }
WorldDworph >> render: props [

	| apps worldPortalRef head left right children provided |
	apps := self useState: OrderedCollection new.
	head := self useState: Matrix4x4 identity.
	left := self useState: Matrix4x4 identity.
	right := self useState: Matrix4x4 identity.
	
	worldPortalRef := self useRef: nil.
	
	provided := Array streamContents: [:stream | (Pragma allNamed: #provider in: self class) do: [:pragma | stream nextPutAll: (self perform: pragma selector)]].
	
	children := (props at: #children) isCollection
		ifTrue: [props at: #children]
		ifFalse: [{props at: #children}].
	^ GRProvider
		values: provided, {
			#openApplication -> [:appDescription |
				apps set: [:old | old copyWith: appDescription].
				appDescription].
			#closeApplication -> [:appDescription | apps set: [:old | old copyWithout: appDescription]].
			#applications -> apps get.
			#worldPortal -> worldPortalRef.
			#headTransform -> head get.
			#leftControllerTransform -> left get.
			#rightControllerTransform -> right get}
		children: {
			Avatar new
				left: left get;
				right: right get;
				head: head get;
				setLeft: left setter;
				setRight: right setter;
				setHead: head setter.
			GDSpatial new children: children, (apps get collect: [:appDescription | appDescription buildComponent key: appDescription]), {GDSpatial new ref: worldPortalRef}}
]

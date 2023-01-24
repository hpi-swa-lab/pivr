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

{ #category : #'drag and drop' }
WorldDworph >> provideDragAndDropHandlers [
	<provider>
	
	| draggedHandles dropInfos |
	draggedHandles := self useState: Dictionary new.
	dropInfos := self useState: Dictionary new.
	
	^ {
		#beginDraggingHandle -> [:handle :areaRef |
			draggedHandles set: [:old | old copyWith: handle -> areaRef]].
		#stopDraggingHandle -> [:handle |
			draggedHandles set: [:old | old copyWithoutKey: handle]].
		#handRefForDragHandle -> [:handle |
			draggedHandles get at: handle
				ifAbsent: [nil]].
		#registerDropArea -> [:area :info | dropInfos set: [:old | old copyWith: (area -> info)]].
		#unregisterDropArea -> [:area | dropInfos set: [:old | old copyWithoutKey: area]].
		#getDropAreaInfo -> [:area | dropInfos get at: area]}
]

{ #category : #rendering }
WorldDworph >> provideInteractivity [
	<provider>
	
	| handLocks |
	handLocks := self useState: Dictionary new.

	^ {
		#actingAreaRefToHandRef -> (self useRef: Dictionary new).
		#eventReceivers -> (self useRef: OrderedCollection new).
		#handLocks -> handLocks.
		#acquireHandLock -> [:handRef :handle :successBlock :failBlock |
			(handLocks get associationsSelect: [:assoc | assoc key get = handRef])
				associations
					ifEmpty: [self error: 'Attempted to acquire unregistered hand']
					ifNotEmpty: [:assocs | | selectedAssoc |
						self assert: assocs size = 1 description: 'Multiple hands found'.
						selectedAssoc := assocs first.
						selectedAssoc value
							ifNil: [
								handLocks set: [:old | old copy at: selectedAssoc key put: handle; yourself].
								successBlock value]
							ifNotNil: [failBlock value]]].
		#releaseHandLock -> [:handle | | released |
			released := false.
			handLocks get keysAndValuesDo: [:key :value |
				value = handle ifTrue: [
					released := true.
					handLocks set: [:old | old copy at: key put: nil; yourself]]].
			released].
		#registerHandleInContainer -> [:x | self error: 'No container for container-bound draggable area']}
]

{ #category : #rendering }
WorldDworph >> provideResourceCache [

	| cache |
	cache := self useRef: Dictionary new.
	^ {#resoureCache -> cache get}
]

{ #category : #rendering }
WorldDworph >> provideTextFocus [
	<provider>

	| textFocus |
	textFocus := self useState: GRTextFocus none.
	^ {#textFocus -> textFocus}
]

{ #category : #rendering }
WorldDworph >> render: props [

	| apps worldPortalRef head left right children provided headPortalRef headRef |
	apps := self useState: OrderedCollection new.
	head := self useState: Matrix4x4 identity.
	left := self useState: Matrix4x4 identity.
	right := self useState: Matrix4x4 identity.
	
	headRef := self useGodotRef.
	worldPortalRef := self useRef: nil.
	headPortalRef := self useRef: nil.
	
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
			#headRef -> headRef.
			#headTransform -> head get.
			#leftControllerTransform -> left get.
			#rightControllerTransform -> right get.
			#headPortal -> headPortalRef}
		children: {
			Avatar new
				left: left get;
				right: right get;
				head: head get;
				setLeft: left setter;
				setRight: right setter;
				setHead: head setter;
				headRef: headRef;
				headPortalRef: headPortalRef.
			GDSpatial new ref: worldPortalRef}, children, (self renderApps: apps get)
]

{ #category : #rendering }
WorldDworph >> renderApps: apps [

	| environmentApp regularApps |
	environmentApp := ((apps select: [:app | app rendersEnvironment]) detectMax: [:p | p priority])
		ifNotNil: [:a | {a}]
		ifNil: [{}].
	regularApps := apps reject: [:app | app rendersEnvironment].
	
	^ regularApps, environmentApp collect: [:appDescription | appDescription buildComponent key: appDescription]
]

{ #category : #rendering }
WorldDworph >> renderSplitscreen: props [

	" draft for enabling splitscreen rendering, for example when trying to show VR from both 1st and 3rd person on a PC "
	| viewportRef |
	viewportRef := self useGodotRef.
	^ GDMarginContainer new anchorRight: 1; anchorBottom: 1; children: {GDGridContainer new columns: 2; children: {
			GDViewportContainer new stretch: true; sizeFlagsHorizontal: GDControl sizeExpandFill; sizeFlagsVertical: GDControl sizeExpandFill; children: {
				GDViewport new
					ref: viewportRef;
					size: 100 @ 100;
					children: {
						Avatar new
							" ... "
							viewportRef: viewportRef}.
			GDViewportContainer new stretch: true; sizeFlagsHorizontal: GDControl sizeExpandFill; sizeFlagsVertical: GDControl sizeExpandFill; children:
				{GDViewport new children: GDCamera new}}}}
]

Class {
	#name : #GRDraggableArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRDraggableArea >> render: props [

	| beginDraggingHandle stopDraggingHandle isDragged handRef inPlaceRef |
	props extract: [:handle :onDragBegin :onDragEnd :onButtonPress :onButtonRelease :transform :rest |
		beginDraggingHandle := self useProvided: #beginDraggingHandle.
		stopDraggingHandle := self useProvided: #stopDraggingHandle.
		inPlaceRef := self useRef: nil.
		handRef := (self useProvided: #handRefForDragHandle) value: handle.
		isDragged := handRef notNil.
		
		^ GDSpatial new
			ref: inPlaceRef;
			transform: (isDragged ifTrue: [Matrix4x4 identity] ifFalse: [transform]);
			children: {
				CMFReactNodePortal
					child: {
						GRInteractiveArea new
							props: rest;
							onButtonPress: [:event |
								(event isGrip and: [isDragged not]) ifTrue: [
									event
										acquireGrab: [
											beginDraggingHandle value: handle value: event controllerRef.
											onDragBegin ifNotNil: [:block | block cull: event]]
										ifBlocked: []].
								onButtonPress ifNotNil: [:block | block cull: event]];
							onButtonRelease: [:event |
								(event isGrip and: isDragged) ifTrue: [
									event releaseGrab.
									stopDraggingHandle value: handle.
									onDragEnd ifNotNil: [:block | block cull: event]].
								onButtonRelease ifNotNil: [:block | block cull: event]]}
					in: (handRef ifNil: [inPlaceRef])}]
]

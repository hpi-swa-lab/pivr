Class {
	#name : #GRDraggableArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRDraggableArea >> render: props [

	props extract: [:handle :onButtonPress :onButtonRelease :onDragBegin :onDragEnd :releaseCondition :transform || inPlaceRef handLocks acquireHandLock heldHandRef releaseHandLock endGrab fallbackHandle isDragged realHandle realReleaseCondition registerHandleInContainer currentTransform |
		realReleaseCondition := releaseCondition ifNil: [#selfUnmount].
		fallbackHandle := self useMemo: [GRReact nextGodotId] dependencies: #().
		realHandle := handle
			ifNil: [realReleaseCondition = #selfUnmount
				ifTrue: [fallbackHandle]
				ifFalse: [self error: ('The handle property of a {1} may not be nil' format: {self class})]].
		
		inPlaceRef := self useRef: nil.
		handLocks := self useProvided: #handLocks.
		acquireHandLock := self useProvided: #acquireHandLock.
		releaseHandLock := self useProvided: #releaseHandLock.
		registerHandleInContainer := self useProvided: #registerHandleInContainer.
		currentTransform := self useState: Matrix4x4 identity.
		
		heldHandRef := handLocks get associations detect: [:assoc | assoc value = realHandle]
			ifFound: [:assoc | assoc key]
			ifNone: [nil].
		isDragged := heldHandRef notNil.
		
		endGrab := [
			releaseHandLock value: realHandle.
			onDragEnd ifNotNil: [onDragEnd value]].
		self useEffect: [
			realReleaseCondition = #containerUnmount ifTrue: [
				registerHandleInContainer value: realHandle].
			
			[realReleaseCondition = #selfUnmount ifTrue: [endGrab value]]]
			dependencies: #().
		
		^ GDSpatial new
			ref:  inPlaceRef;
			children: {
				CMFReactNodePortal
					child: {
					GRInteractiveArea new
						props: (props copyWithoutKeys: #(handle));
						exclusiveHandRef: (heldHandRef ifNotNil: [heldHandRef get]);
						transform: (isDragged ifTrue: [Matrix4x4 identity] ifFalse: [transform ifNil: [currentTransform get]]);
						onButtonPress: [:event |
							acquireHandLock
								value: event handRef
								value: realHandle
								value: [
									onDragBegin ifNotNil: [onDragBegin cull: event]
									]
								value: ["do nothing"].
							onButtonPress ifNotNil: [onButtonPress cull: event]];
						onButtonRelease: [:event |
							currentTransform set: event transform.
							releaseHandLock value: realHandle.
							onButtonRelease ifNotNil: [onButtonRelease cull: event].
							endGrab value]}
					in: (heldHandRef ifNil: [inPlaceRef])}]
]

{ #category : #'as yet unclassified' }
GRDraggableArea >> renderOld: props [

	props extract: [:handle :onDragBegin :onDragEnd :onButtonPress :onButtonRelease :transform :rest | | overlappingDropAreas beginDraggingHandle getDropAreaInfo handRef inPlaceRef isDragged stopDraggingHandle |
		beginDraggingHandle := self useProvided: #beginDraggingHandle.
		stopDraggingHandle := self useProvided: #stopDraggingHandle.
		getDropAreaInfo := self useProvided: #getDropAreaInfo.
		inPlaceRef := self useRef: nil.
		handRef := (self useProvided: #handRefForDragHandle) value: handle.
		isDragged := handRef notNil.
		overlappingDropAreas := self useState: OrderedCollection new.
		
		^ GDSpatial new
			ref: inPlaceRef;
			transform: (isDragged ifTrue: [Matrix4x4 identity] ifFalse: [transform]);
			children: {
				CMFReactNodePortal
					child: {
						GDArea new
							collisionMask: GRDropArea dropLayer;
							collisionLayer: 0;
							onAreaEntered: [:area |
								Transcript showln: 'started overlapping ', area asString.
								overlappingDropAreas set: [:old | old copyWith: area].
								Transcript showln: overlappingDropAreas get asString, ' ', overlappingDropAreas get identityHash asString];
							onAreaExited: [:area |
								Transcript showln: 'stopped overlapping ', area asString.
								overlappingDropAreas set: [:old | old copyWithout: area].
								Transcript showln: overlappingDropAreas get];
							children: {
								GDCollisionShape new
									shape: (GDSphereShape new radius: 0.01)}.
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
									onDragEnd ifNotNil: [:block |
										Transcript showln: 'overlapping areas at drag end ', overlappingDropAreas get asString, ' ', overlappingDropAreas get identityHash asString.
										block
											cull: event
											cull: (overlappingDropAreas get
												ifEmpty: [nil]
												ifNotEmpty: [:areas |
													"TODO: choose better"
													getDropAreaInfo value: areas first])]].
								onButtonRelease ifNotNil: [:block | block cull: event]]}
					in: (handRef ifNil: [inPlaceRef])}]
]

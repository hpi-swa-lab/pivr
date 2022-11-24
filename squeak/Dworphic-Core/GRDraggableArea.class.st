Class {
	#name : #GRDraggableArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRDraggableArea >> render: props [

	props extract: [:handle :onButtonPress :onButtonRelease :onGrab :onRelease :releaseCondition :transform | | inPlaceRef handLocks acquireHandLock heldHandRef releaseHandLock endGrab fallbackHandle isDragged realHandle realReleaseCondition registerHandleInContainer currentTransform |
		realReleaseCondition := releaseCondition ifNil: [#selfUnmount].
		fallbackHandle := self useMemo: [GRReact nextGodotId] dependencies: #().
		realHandle := handle ifNil: [
			realReleaseCondition = #selfUnmount
				ifTrue: [fallbackHandle]
				ifFalse: [self error: ('The handle property of a {1} may not be nil' format: {self class})]].
		
		inPlaceRef := self useRef: nil.
		handLocks := self useProvided: #handLocks.
		acquireHandLock := self useProvided: #acquireHandLock.
		releaseHandLock := self useProvided: #releaseHandLock.
		registerHandleInContainer := self useProvided: #registerHandleInContainer.
		currentTransform := self useState: Matrix4x4 identity.
		
		heldHandRef := handLocks get associations
			detect: [:assoc | assoc value = realHandle]
			ifFound: [:assoc | assoc key]
			ifNone: [nil].
		isDragged := heldHandRef notNil.
		
		endGrab := [:eventOrNil |
			releaseHandLock value: realHandle.
			onRelease ifNotNil: [onRelease cull: eventOrNil]].
		self
			useEffect: [
				realReleaseCondition = #containerUnmount ifTrue: [registerHandleInContainer value: realHandle].
				
				[realReleaseCondition = #selfUnmount ifTrue: [endGrab value]]]
			dependencies: #().
		
		^ GDSpatial new
			ref: inPlaceRef;
			children: {
				CMFReactNodePortal
					child: {
						GRInteractiveArea new
							props: (props copyWithoutKeys: #(#handle));
							exclusiveHandRef: (heldHandRef ifNotNil: [heldHandRef get]);
							transform: (isDragged ifTrue: [Matrix4x4 identity] ifFalse: [transform ifNil: [currentTransform get]]);
							onButtonPress: [:event |
								event isGrip ifTrue: [
									acquireHandLock
										value: event handRef
										value: realHandle
										value: [onGrab ifNotNil: [onGrab cull: event]]
										value: []].
								onButtonPress ifNotNil: [onButtonPress cull: event]];
							onButtonRelease: [:event |
								onButtonRelease ifNotNil: [onButtonRelease cull: event].
								event isGrip ifTrue: [
									currentTransform set: event transform.
									endGrab value: event]]}
					in: (heldHandRef ifNil: [inPlaceRef])}]
]

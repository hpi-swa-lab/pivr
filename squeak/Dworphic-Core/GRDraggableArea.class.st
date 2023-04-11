Class {
	#name : #GRDraggableArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRDraggableArea >> render: props [

	props extract: [:handle :onButtonPress :onButtonRelease :onGrab :onRelease :releaseCondition :transform :api | | inPlaceRef handLocks acquireHandLock heldHandRef releaseHandLock endGrab fallbackHandle isDragged realHandle realReleaseCondition registerHandleInContainer currentTransform endGrabFake startGrab grabOffsetTransform objectTransform parentRef originalParentTransform |
		realReleaseCondition := releaseCondition ifNil: [#selfUnmount].
		parentRef := self useGodotRef.
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
		grabOffsetTransform := self useState: Matrix4x4 identity.
		
		heldHandRef := handLocks get associations
			detect: [:assoc | assoc value = realHandle]
			ifFound: [:assoc | assoc key]
			ifNone: [nil].
		isDragged := heldHandRef notNil.
		
		startGrab := [:event |
			acquireHandLock
				value: event handRef
				value: realHandle
				value: [
					onGrab ifNotNil: [
						event handle: handle.
						onGrab cull: event]]
				value: []].
		endGrab := [:eventOrNil |
			releaseHandLock value: realHandle.
			onRelease ifNotNil: [onRelease cull: eventOrNil]].
		endGrabFake := [isDragged ifTrue: [endGrab value: GRInteractiveAreaEvent fake]].
		self
			useEffect: [
				realReleaseCondition = #containerUnmount ifTrue: [registerHandleInContainer value: realHandle].
				
				[realReleaseCondition = #selfUnmount ifTrue: [endGrabFake value]]]
			dependencies: #().
		
		api ifNotNil: [
			api
				at: #endGrab put: endGrabFake;
				at: #startGrab put: startGrab;
				at: #setGrabOffset put: grabOffsetTransform setter].
		
		objectTransform := transform ifNil: [currentTransform get].
		
		originalParentTransform := self useState: Matrix4x4 identity.
		
		^ GDSpatial new
			subscribeTo: 'global_transform' do: [:t | "dummy node to always get transform of the virtual parent"
			originalParentTransform set: t];
			children: {
				GDSpatial new
					ref: [:val |
						inPlaceRef value: val.
						parentRef value: val];
					children: {
						CMFReactNodePortal
							child: {
								GRInteractiveArea new
									props: (props copyWithoutKeys: #(#handle #api));
									exclusiveHandRef: (heldHandRef ifNotNil: [heldHandRef get]);
									transform: (isDragged ifTrue: [grabOffsetTransform get] ifFalse: [objectTransform]);
									onButtonPress: [:event |
										event isGrip ifTrue: [ | g |
											g := parentRef get globalTransform.
											grabOffsetTransform set: event transform inverseTransformation * (g * objectTransform).
											startGrab value: event].
										onButtonPress ifNotNil: [
											event handle: handle.
											onButtonPress cull: event]];
									onButtonRelease: [:event |
										event handle: handle.
										onButtonRelease ifNotNil: [onButtonRelease cull: event].
										(event isGrip and: isDragged) ifTrue: [
											"currentTransform set: event transform * grabOffsetTransform get."
											currentTransform set: originalParentTransform get inverseTransformation * event transform * grabOffsetTransform get.
											event transform: currentTransform get.
											endGrab value: event]]}
							in: (heldHandRef ifNil: [inPlaceRef])}}]
]

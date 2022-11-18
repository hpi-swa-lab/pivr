Class {
	#name : #GRInteractiveArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRInteractiveArea class >> pointLayer [

	^ 1 bitShift: 31
]

{ #category : #'as yet unclassified' }
GRInteractiveArea class >> touchLayer [

	^ 1 bitShift: 30
]

{ #category : #'as yet unclassified' }
GRInteractiveArea >> render: props [

	^ props extract: [:children :onHover :onBlur :onButtonPress :onButtonRelease :touch :point :exclusiveHandRef :rest | | overlappingActingAreas actingAreaRefToHandRef eventReceivers handlers isOverlappingHand eventIsRelevant |
		overlappingActingAreas := self useState: {}.
		actingAreaRefToHandRef := self useProvided: #actingAreaRefToHandRef.
		
		isOverlappingHand := [:handRef |
			overlappingActingAreas get anySatisfy: [:actingAreaRef | 
				(actingAreaRefToHandRef get at: actingAreaRef) get = handRef]].
		
		eventIsRelevant := [:event |
			exclusiveHandRef
				ifNil: [isOverlappingHand value: event handRef]
				ifNotNil: [event handRef = exclusiveHandRef]].
		
		handlers := self useRef: nil.
		handlers set: (#(onButtonPress onButtonRelease #onAxisChange) collect: [:symbol |
			symbol -> [:event |
				(eventIsRelevant value: event)
					ifTrue: [props at: symbol ifPresent: [:block | block cull: event]]]] as: Dictionary).
		
		eventReceivers := self useProvided: #eventReceivers.
		self useEffect: [
			eventReceivers get add: handlers.
			[eventReceivers get remove: handlers]] dependencies: #().

		GDArea new
			setAll: rest;
			collisionMask: 0;
			collisionLayer:
				(((touch ifNil: [true]) ifTrue: [self class touchLayer] ifFalse: [0])
				bitOr: ((point ifNil: [false]) ifTrue: [self class pointLayer] ifFalse: [0]));
			onAreaEntered: [:area | | areaHandRef |
				areaHandRef := actingAreaRefToHandRef get at: area.
				(onHover ifNotNil: [:block |
					(isOverlappingHand value: areaHandRef)
						ifFalse: [
							block cull: (GRInteractiveAreaEvent new
								side: #nyi;
								handRef: areaHandRef)]]).
				overlappingActingAreas set: [:old | old copyWith: area]];
			onAreaExited: [:area |
				actingAreaRefToHandRef get at: area ifPresent: [:areaHandRef |
					overlappingActingAreas set: [:old | old copyWithout: area].
					(onBlur ifNotNil: [:block |
						(isOverlappingHand value: areaHandRef)
							ifFalse: [
								block cull: (GRInteractiveAreaEvent new
									side: #nyi;
									handRef: areaHandRef)]])]];
			children: children]
]

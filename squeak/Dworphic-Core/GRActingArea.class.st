Class {
	#name : #GRActingArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRActingArea >> render: props [

	| actingAreaRefToHandRef areaRef |
	props extract: [:handRef :touch :point :children :rest |
		areaRef := self useGodotRef.
		actingAreaRefToHandRef := self useProvided: #actingAreaRefToHandRef.
		self useEffect: [
			actingAreaRefToHandRef get at: areaRef get put: handRef get.
			[actingAreaRefToHandRef get removeKey: areaRef get]].
		
		^ GDArea new
			ref: areaRef;
			setAll: rest;
			collisionLayer: 0;
			collisionMask:
				((touch ifTrue: [GRInteractiveArea touchLayer] ifFalse: [0])
				bitOr: (point ifTrue: [GRInteractiveArea pointLayer] ifFalse: [0]));
			children: children]
]

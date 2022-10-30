Class {
	#name : #GRActingArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRActingArea >> render: props [

	| areaRef |
	^ props extract: [:setHandlers :side :actingTransform :controllerRef :children :touch :point :rest |
		areaRef := self useGodotRef.
		setHandlers value: (self useActiveEventHandlersFor: areaRef side: side transform: actingTransform controller: controllerRef type: (point ifTrue: [#point] ifFalse: [#touch])).
		^ GDArea new
			setAll: rest;
			ref: areaRef;
			collisionLayer: 0;
			collisionMask: ((touch ifTrue: [GRInteractiveArea touchLayer] ifFalse: [0]) bitOr: (point ifTrue: [GRInteractiveArea pointLayer] ifFalse: [0]));
			children: children]
]

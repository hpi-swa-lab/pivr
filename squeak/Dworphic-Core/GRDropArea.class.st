Class {
	#name : #GRDropArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRDropArea class >> dropLayer [

	^ 1 bitShift: 29
]

{ #category : #'as yet unclassified' }
GRDropArea >> render: props [

	| areaRef registerDropArea unregisterDropArea |
	self deprecated: 'Check for overlapping areas in onRelease instead'.
	registerDropArea := self useProvided: #registerDropArea.
	unregisterDropArea := self useProvided: #unregisterDropArea.
	areaRef := self useGodotRef.
	self useEffect: [
		registerDropArea value: areaRef get value: (props at: #info ifAbsent: [nil]).
		[unregisterDropArea value: areaRef get]] dependencies: #().

	^ GDArea new
		setAll: (props copyWithoutKey: #info);
		ref: areaRef;
		collisionMask: 0;
		collisionLayer: self class dropLayer;
		children: {props at: #children}
]

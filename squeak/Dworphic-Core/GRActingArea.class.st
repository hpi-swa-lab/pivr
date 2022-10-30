Class {
	#name : #GRActingArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRActingArea >> render: props [

	| areaRef |
	areaRef := self useGodotRef.

	"TODO: consider moving the useActiveEventHandlersFor... hook into this class"
	(props at: #setHandlers) value: (self
		useActiveEventHandlersFor: areaRef
		side: (props at: #side)
		transform: (props at: #actingTransform)
		controller: (props at: #controllerRef)
		type: (props at: #type)).
		
	^ GDArea new
		"TODO"
		"setAll: props;"
		ref: areaRef;
		children: (props at: #children)
]

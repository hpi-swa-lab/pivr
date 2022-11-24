Class {
	#name : #GRGrabbableArea,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRGrabbableArea >> render: props [

	"self deprecated."
	^ GRDraggableArea new
		props: props
]

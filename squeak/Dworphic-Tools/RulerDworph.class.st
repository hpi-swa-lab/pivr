Class {
	#name : #RulerDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Tools'
}

{ #category : #'as yet unclassified' }
RulerDworph class >> appDescription [
	<home>

	^ super appDescription
]

{ #category : #'as yet unclassified' }
RulerDworph >> render: props [

	^ GRDraggableArea new
		children: {
			GDCollisionShape new
				shape: (GDBoxShape new
					extents: 0.5cm @ 0.5m @ 0.5cm)},
			((1 to: 10) collect: [:i | | even |
				even := i isDivisibleBy: 2.
				(self methodAsComponent: #renderDecimeter:)
					translation: 0 @ ((i - 1) * 10cm - 49.5cm) @ 0;
					colorA: (even ifTrue: [Color red] ifFalse: [Color yellow]);
					colorB: (even ifTrue: [Color blue] ifFalse: [Color green])])
]

{ #category : #'as yet unclassified' }
RulerDworph >> renderDecimeter: props [

	| translation |
	translation := props at: #translation.
	^ (1 to: 10) collect: [:i | | color |
		color := (i isDivisibleBy: 2)
			ifTrue: [props at: #colorA]
			ifFalse: [props at: #colorB].
		(self cubeVisualOfSize: 1cm color: color)
			translation: translation + (0 @ ((i - 1) * 1cm) @ 0)]
]

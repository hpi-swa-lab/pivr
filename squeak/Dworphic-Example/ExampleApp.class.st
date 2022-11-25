Class {
	#name : #ExampleApp,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
ExampleApp >> render: props [

	^ ApplicationDworph new
		children: {
			GRDraggableArea new
				transform: (Matrix4x4 withOffset: 0 @ 1 @ 0);
				handle: 1;
				children: {self cubeOfSize: 0.5 color: Color green}}
]

Class {
	#name : #ExampleApp,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
ExampleApp >> render: props [

	^ ApplicationDworph new
		children: {
			GRInteractiveArea new
				onButtonPress: [:event | Transcript showln: 'pressed ', event button];
				children: {self cubeOfSize: 0.5 color: Color green}}
]

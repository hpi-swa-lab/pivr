Class {
	#name : #CubeExample,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
CubeExample >> render: props [

	^ AlternativeWorldDworph new children: {
		[
			self useApplication: [CubeApp appDescription] dependencies: {}.
			nil] asComponent}
]

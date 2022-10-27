Class {
	#name : #CubeExample,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
CubeExample >> render: props [

	^ AlternativeWorldDworph new children: {
		Avatar new.
		[
			self useApplication: [CubeApp appDescription] dependencies: {}.
			nil] asComponent}
]

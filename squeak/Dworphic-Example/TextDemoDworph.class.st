Class {
	#name : #TextDemoDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
TextDemoDworph class >> appDescription [
	<home>

	^ super appDescription
]

{ #category : #'as yet unclassified' }
TextDemoDworph >> render: props [

	^ {
		TextInputDworph new transform: ((Matrix4x4 lookAt: 0 @ 1 @ 0 from: 0.5 @ 1 @ 0 up: 0 @ 1 @ 0) rotatedLocalBy: 180 around: 0 @ 1 @ 0).
		TextInputDworph new transform: ((Matrix4x4 lookAt: 0 @ 1 @ 0 from: 0 @ 1 @ 0.5 up: 0 @ 1 @ 0) rotatedLocalBy: 180 around: 0 @ 1 @ 0)
	}
]

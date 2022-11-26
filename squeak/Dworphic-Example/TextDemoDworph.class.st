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

	^ {TextInputDworph new}
]

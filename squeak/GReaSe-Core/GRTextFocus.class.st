Class {
	#name : #GRTextFocus,
	#superclass : #Object,
	#instVars : [
		'textEnteredCallback',
		'textAreaTopLeft',
		'cursorTransform',
		'textAreaExtent'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRTextFocus class >> none [

	^ self new
]

{ #category : #'as yet unclassified' }
GRTextFocus class >> textAreaTopLeft: aTranform extent: aPoint cursor: aTransform [

	^ self new
		textAreaTopLeft: aTranform;
		textAreaExtent: aPoint;
		cursorTransform: aTransform
]

{ #category : #'as yet unclassified' }
GRTextFocus >> cursorTransform [

	^ cursorTransform
]

{ #category : #'as yet unclassified' }
GRTextFocus >> cursorTransform: aTransform [

	cursorTransform := aTransform
]

{ #category : #'as yet unclassified' }
GRTextFocus >> initialize [

	super initialize.
	
	textAreaExtent := 0 @ 0.
	textAreaTopLeft := Matrix4x4 identity.
	cursorTransform := Matrix4x4 identity.
	textEnteredCallback := [:text | ]
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textAreaExtent [

	^ textAreaExtent
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textAreaExtent: aPoint [

	textAreaExtent := aPoint
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textAreaTopLeft [

	^ textAreaTopLeft
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textAreaTopLeft: aTransform [

	textAreaTopLeft := aTransform
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textEnteredCallback [

	^ textEnteredCallback
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textEnteredCallback: aBlock [

	textEnteredCallback := aBlock
]

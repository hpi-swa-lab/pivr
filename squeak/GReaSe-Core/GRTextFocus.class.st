Class {
	#name : #GRTextFocus,
	#superclass : #Object,
	#instVars : [
		'textEnteredCallback',
		'cursorTransform',
		'textAreaExtent',
		'textAreaCenter'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRTextFocus class >> none [

	^ self new
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
	textAreaCenter := Matrix4x4 identity.
	cursorTransform := Matrix4x4 identity.
	textEnteredCallback := nil
]

{ #category : #'as yet unclassified' }
GRTextFocus >> notNone [

	^ textEnteredCallback notNil
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textAreaBottomCenter [

	^ self textAreaCenter localTranslatedBy: 0 @ self textAreaExtent y
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textAreaCenter [

	^ textAreaCenter
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textAreaCenter: aTransform [

	textAreaCenter := aTransform
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

	^ textAreaCenter localTranslatedBy: textAreaExtent / 2 @ 0
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textEnteredCallback [

	^ textEnteredCallback
]

{ #category : #'as yet unclassified' }
GRTextFocus >> textEnteredCallback: aBlock [

	textEnteredCallback := aBlock
]

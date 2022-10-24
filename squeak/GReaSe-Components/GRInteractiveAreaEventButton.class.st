Class {
	#name : #GRInteractiveAreaEventButton,
	#superclass : #GRInteractiveAreaEvent,
	#instVars : [
		'button'
	],
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventButton >> button [

	^ button
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventButton >> button: aNumber [

	button := aNumber
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventButton >> isGrip [

	^ self button = GDGlobalConstants joyVrGrip
]

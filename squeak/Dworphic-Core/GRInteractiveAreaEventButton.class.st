Class {
	#name : #GRInteractiveAreaEventButton,
	#superclass : #GRInteractiveAreaEvent,
	#instVars : [
		'button'
	],
	#category : #'Dworphic-Core'
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
GRInteractiveAreaEventButton >> isAX [

	^ self button = GDGlobalConstants joyOculusAx
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventButton >> isBY [

	^ self button = GDGlobalConstants joyOculusBy
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventButton >> isGrip [

	^ self button = GDGlobalConstants joyVrGrip
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventButton >> isTrigger [

	^ self button = GDGlobalConstants joyVrTrigger
]

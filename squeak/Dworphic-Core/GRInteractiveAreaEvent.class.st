Class {
	#name : #GRInteractiveAreaEvent,
	#superclass : #Object,
	#instVars : [
		'controllerRef',
		'side',
		'transform',
		'grabState'
	],
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> acquireGrab: aBlock ifBlocked: anotherBlock [

	grabState set: [:current |
		current ifFalse: [aBlock value] ifTrue: [anotherBlock value].
		true]
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> controllerRef [

	  ^ controllerRef
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> controllerRef: aRemoteRef [

	controllerRef := aRemoteRef
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> grabState: aState [

	grabState := aState
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> releaseGrab [

	grabState set: false
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> side [

	^ side
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> side: aSymbol [

	side := aSymbol
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> transform [

	^ transform
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> transform: aMatrix4x4 [

	transform := aMatrix4x4
]

Class {
	#name : #GRInteractiveAreaEvent,
	#superclass : #Object,
	#instVars : [
		'controllerRef',
		'side',
		'transform'
	],
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> controllerRef [

	  ^ controllerRef
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> controllerRef: aRemoteRef [

	controllerRef := aRemoteRef
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

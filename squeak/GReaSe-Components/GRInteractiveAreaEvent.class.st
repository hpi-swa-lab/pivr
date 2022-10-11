Class {
	#name : #GRInteractiveAreaEvent,
	#superclass : #Object,
	#instVars : [
		'controllerRef',
		'side'
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

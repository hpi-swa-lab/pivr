Class {
	#name : #GRInteractiveAreaEvent,
	#superclass : #Object,
	#instVars : [
		'controllerRef',
		'side',
		'transform',
		'grabState',
		'targetHandlers',
		'grabRelease',
		'type'
	],
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> acquireGrab: aBlock ifBlocked: anotherBlock [

	grabState set: [:current |
		current
			ifNil: [
				aBlock value.
				targetHandlers]
			ifNotNil: [
				anotherBlock value.
				current]]
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
GRInteractiveAreaEvent >> grabRelease: aClosure [

	grabRelease := aClosure
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> grabState: aState [

	grabState := aState
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> releaseGrab [

	grabState set: [:current |
		current = targetHandlers
			ifTrue: [
				grabRelease value: targetHandlers.
				nil]
			ifFalse: [current]]
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
GRInteractiveAreaEvent >> targetHandlers: handlers [

	targetHandlers := handlers
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> transform [

	^ transform
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> transform: aMatrix4x4 [

	transform := aMatrix4x4
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> type [

	^ type
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> type: aSymbol [

	type := aSymbol
]

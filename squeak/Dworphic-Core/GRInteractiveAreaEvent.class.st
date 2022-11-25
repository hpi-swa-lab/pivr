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
		'type',
		'handRef',
		'handRef2'
	],
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent class >> fake [

	^ GRInteractiveAreaEvent new
		side: #none;
		transform: Matrix4x4 identity
]

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
GRInteractiveAreaEvent >> handRef [

	^ handRef
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> handRef2 [

	^ handRef2
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> handRef2: aRef [

	handRef2 := aRef
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEvent >> handRef: anObject [

	handRef := anObject
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

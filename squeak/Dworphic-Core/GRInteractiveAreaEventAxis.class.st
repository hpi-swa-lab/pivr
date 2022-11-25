Class {
	#name : #GRInteractiveAreaEventAxis,
	#superclass : #GRInteractiveAreaEvent,
	#instVars : [
		'axis',
		'strength'
	],
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventAxis >> axis [

	^ axis
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventAxis >> axis: aNumber [

	axis := aNumber
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventAxis >> isGrip [

	^ self axis = GDGlobalConstants joyVrAnalogGrip
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventAxis >> isStickX [

	^ self axis = GDGlobalConstants joyAnalogLx
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventAxis >> isStickY [

	^ self axis = GDGlobalConstants joyAnalogLy
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventAxis >> isTrigger [

	^ self axis = GDGlobalConstants joyVrAnalogTrigger
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventAxis >> strength [

	^ strength
]

{ #category : #'as yet unclassified' }
GRInteractiveAreaEventAxis >> strength: aNumber [

	strength := aNumber
]

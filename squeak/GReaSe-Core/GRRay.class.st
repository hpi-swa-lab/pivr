Class {
	#name : #GRRay,
	#superclass : #Object,
	#instVars : [
		'origin',
		'direction'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRRay class >> origin: aVector direction: anotherVector [

	^ self new origin: aVector direction: anotherVector
]

{ #category : #'as yet unclassified' }
GRRay >> intersectPlane: aPlaneOriginVector normal: aPlaneNormalVector [

	| denom |
	denom := aPlaneNormalVector dot: direction.
	^ (denom closeTo: 0)
		ifFalse: [ | t |
			t := aPlaneOriginVector - origin / denom.
			origin + (t * direction)]
		ifTrue: [nil]
]

{ #category : #'as yet unclassified' }
GRRay >> origin: aVector direction: anotherVector [

	origin := aVector.
	direction := anotherVector
]

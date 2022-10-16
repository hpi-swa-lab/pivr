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
GRRay class >> forCamera: aSpatial [

	| camera origin position direction |
	camera := (aSpatial getTree root grAsClass: #GDViewport) getCamera.
	origin := camera projectRayOriginScreenPoint: position.
	direction := (camera projectRayNormalScreenPoint: position) normalized.
	^ self origin: origin direction: direction
]

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
			t := (aPlaneOriginVector - origin dot: aPlaneNormalVector) / denom.
			origin + (t * direction)]
		ifTrue: [nil]
]

{ #category : #'as yet unclassified' }
GRRay >> origin: aVector direction: anotherVector [

	origin := aVector.
	direction := anotherVector
]

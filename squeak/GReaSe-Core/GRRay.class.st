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
GRRay class >> forCamera: aSpatial point: aPoint [

	| camera origin direction |
	camera := (aSpatial getTree root grAsClass: #GDViewport) getCamera.
	origin := camera projectRayOriginScreenPoint: aPoint.
	direction := (camera projectRayNormalScreenPoint: aPoint) normalized.
	^ self origin: origin direction: direction
]

{ #category : #'as yet unclassified' }
GRRay class >> origin: aVector direction: anotherVector [

	^ self new origin: aVector direction: anotherVector
]

{ #category : #'as yet unclassified' }
GRRay >> direction [

	^ direction
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
GRRay >> intersectSphere: sphereOrigin radius: sphereRadius [

	| oMinC p q discriminant dRoot |
	oMinC := origin - sphereOrigin.
	p := direction normalized dot: oMinC.
	q := (oMinC dot: oMinC) - (sphereRadius * sphereRadius).
	
	discriminant := p * p - q.
	discriminant < 0 ifTrue: [^ {}].
	
	dRoot := discriminant sqrt.
	^ q < 0
		ifTrue: [self pointFromOrigin: p * -1 + dRoot]
		ifFalse: [self pointFromOrigin: p * -1 - dRoot]
]

{ #category : #'as yet unclassified' }
GRRay >> origin [

	^ origin
]

{ #category : #'as yet unclassified' }
GRRay >> origin: aVector direction: anotherVector [

	origin := aVector.
	direction := anotherVector
]

{ #category : #'as yet unclassified' }
GRRay >> pointFromOrigin: dist [

	^ origin + ((direction normalized) * dist)
]

{ #category : #'as yet unclassified' }
GRRay >> printOn: aStream [

	aStream nextPutAll: self className.
	aStream nextPut: $(.
	aStream print: origin.
	aStream nextPut: $,.
	aStream print: direction.
	aStream nextPut: $)
]

Class {
	#name : #GRRayTest,
	#superclass : #TestCase,
	#category : #'GReaSe-Test'
}

{ #category : #'as yet unclassified' }
GRRayTest >> testIntersectSphere [

	self assert: 0 @ 5 @ 0 equals: ((GRRay origin: 0 @ 0 @ 0 direction: 0 @ 1 @ 0)
		intersectSphere: 0 @ 0 @ 0
		radius: 5)
]

{ #category : #'as yet unclassified' }
GRRayTest >> testIntersectSphereNonOriginRay [

	self assert: 0 @ 5 @ 0 equals: ((GRRay origin: 0 @ 1 @ 0 direction: 0 @ 1 @ 0)
		intersectSphere: 0 @ 0 @ 0
		radius: 5)
]

{ #category : #'as yet unclassified' }
GRRayTest >> testIntersectSphereRotated [

	self assert: (3.51 @ 2.51 @ 2.51 distanceTo: ((GRRay origin: 2 @ 1 @ 1 direction: 1 @ 1 @ 1)
		intersectSphere: 0 @ 0 @ 0
		radius: 5)) < 0.01
]

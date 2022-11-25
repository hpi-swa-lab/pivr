Class {
	#name : #GRMatrixTest,
	#superclass : #TestCase,
	#category : #'GReaSe-Test'
}

{ #category : #'as yet unclassified' }
GRMatrixTest >> testForwardRayRotateX [

	| ray |
	ray := ((Matrix4x4 withOffset: 0 @ 2 @ 0) * (Matrix4x4 withRotation: 90 around: 1 @ 0 @ 0)) forwardRay.
	self assert: (ray origin distanceTo: 0 @ 2 @ 0) < 0.01.
	self assert: (ray direction distanceTo: 0 @ 1 @ 0) < 0.01
]

{ #category : #'as yet unclassified' }
GRMatrixTest >> testForwardRayRotateY [

	| ray |
	ray := ((Matrix4x4 withOffset: 0 @ 2 @ 0) * (Matrix4x4 withRotation: 90 around: 0 @ 1 @ 0)) forwardRay.
	self assert: (ray origin distanceTo: 0 @ 2 @ 0) < 0.01.
	self assert: (ray direction distanceTo: -1 @ 0 @ 0) < 0.01
]

{ #category : #'as yet unclassified' }
GRMatrixTest >> testForwardRayRotateZ [

	| ray |
	ray := ((Matrix4x4 withOffset: 0 @ 2 @ 0) * (Matrix4x4 withRotation: 90 around: 0 @ 0 @ 1)) forwardRay.
	self assert: (ray origin distanceTo: 0 @ 2 @ 0) < 0.01.
	self assert: (ray direction distanceTo: 0 @ 0 @ -1) < 0.01
]

{ #category : #'as yet unclassified' }
GRMatrixTest >> testTransformWithAngle [

	self assert: (((Matrix4x4 withRotation: 90 around: 1 @ 0 @ 0) transform: 0 @ -1 @ 0) distanceTo: 0 @ 0 @ -1) < 0.01
]

{ #category : #'as yet unclassified' }
GRMatrixTest >> testTransformWithTranslation [

	self assert: 0 @ 2 @ 0 equals: ((Matrix4x4 withOffset: 0 @ 1 @ 0) transform: 0 @ 1 @ 0)
]

Class {
	#name : #CubeAppTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
CubeAppTest >> testGrabCube [

	self openComponent: [AlternativeWorldDworph new children: {Avatar new. CubeDworph new color: Color red}].
	
	self tick: {
		(godotTree firstNodeOfType: #RigidBody) children first
			signal: #'area_entered'
			with: {self controllerCollider: #left}}.
	self tick: {(self controllerNode: #left) toggleGrip: true}.
	self tick: {
		(self controllerNode: #left)
			subscribe: #transform
			set: (Matrix4x4 withOffset: 1 @ 2 @ 3)}.
	self tick: {(self controllerNode: #left) toggleGrip: false}.
	self assert: (Matrix4x4 withOffset: 1 @ 2 @ 3) equals: self remoteCalls last last
]

Class {
	#name : #CubeRemoveDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #'as yet unclassified' }
CubeRemoveDworph >> collisionShape [

	^ (self godot: #BoxShape) extents: (self size / 2.0) asVector3
]

{ #category : #'as yet unclassified' }
CubeRemoveDworph >> render: props [

	^ ControllerToolDworph new
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		shape: self collisionShape;
		onRelease: #return;
		active: [(self methodAsComponent: #renderActive:) props: props];
		passive: [(self methodAsComponent: #renderPassive:) props: props]
]

{ #category : #'as yet unclassified' }
CubeRemoveDworph >> renderActive: props [

	| triggerStrength cubes |
	triggerStrength := self useTriggerStrength.
	cubes := self useProvided: #cubes.
	^ (self godot: #Area)
		children: {self renderPassive: props. (self godot: #CollisionShape) shape: self collisionShape};
		area_entered: [:area | | id |
			id := GRReactCurrentSession value
				callOn: area
				method: 'get_meta'
				arguments: {'id'. nil}.
			(triggerStrength > 0.6 and: [id notNil]) ifTrue: [
				cubes set: [:c |
					self assert: (cubes get anySatisfy: [:cube | cube third = id]).
					c select: [:cube | cube third ~= id]]]]
]

{ #category : #'as yet unclassified' }
CubeRemoveDworph >> renderPassive: props [

	^ (self godot: #MeshInstance) mesh: ((self godot: #CubeMesh)
		size: self size asVector3;
		material: ((self godot: #SpatialMaterial) albedo_color: (Color r: 1 g: 0.0 b: 0.0)))
]

{ #category : #'as yet unclassified' }
CubeRemoveDworph >> size [

	^ 0.03
]

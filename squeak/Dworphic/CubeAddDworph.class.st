Class {
	#name : #CubeAddDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #'as yet unclassified' }
CubeAddDworph >> collisionShape [

	^ (self godot: #BoxShape) extents: (self size / 2.0) asVector3
]

{ #category : #'as yet unclassified' }
CubeAddDworph >> render: props [

	^ ControllerToolDworph new
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		shape: self collisionShape;
		onRelease: #return;
		active: [(self methodAsComponent: #renderActive:) props: props];
		passive: [(self methodAsComponent: #renderPassive:) props: props]
]

{ #category : #'as yet unclassified' }
CubeAddDworph >> renderActive: props [

	| controllerTransform triggerStrength cubes once |
	controllerTransform := self useProvidedRef: #controllerTransform.
	triggerStrength := self useTriggerStrength.
	cubes := self useProvided: #cubes.
	once := self useRef: true.
	self
		useEffect: [
			(triggerStrength > 0.6 and: [once get]) ifTrue: [
				once set: false.
				cubes set: [:c | c copyWith: {Color h: 360 atRandom s: 1 v: 1. controllerTransform get. UUID new asString}]].
			triggerStrength = 0 ifTrue: [once set: true]]
		dependencies: {triggerStrength}.
	^ self renderPassive: props
]

{ #category : #'as yet unclassified' }
CubeAddDworph >> renderPassive: props [

	^ (self godot: #MeshInstance) mesh: ((self godot: #CubeMesh)
		size: self size asVector3;
		material: ((self godot: #SpatialMaterial) albedo_color: (Color r: 0.0 g: 1 b: 0.0)))
]

{ #category : #'as yet unclassified' }
CubeAddDworph >> size [

	^ 0.05
]

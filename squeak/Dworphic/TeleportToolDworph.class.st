Class {
	#name : #TeleportToolDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #'as yet unclassified' }
TeleportToolDworph >> collisionShape [

	^ (self godot: #BoxShape) extents: 0.02 @ 0.005 @ 0.03
]

{ #category : #'as yet unclassified' }
TeleportToolDworph >> material [

	^ (self godot: #SpatialMaterial) albedo_color: (Color r: 1 g: 0.4 b: 1)
]

{ #category : #'as yet unclassified' }
TeleportToolDworph >> render: props [

	^ ControllerToolDworph new
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		shape: self collisionShape;
		onRelease: #return;
		active: [(self methodAsComponent: #renderActive:) props: props];
		passive: [
			SBToggledCode
				comment: ''
				active: 1
				do: {[(self methodAsComponent: #renderPassive:) props: props]}]
]

{ #category : #'as yet unclassified' }
TeleportToolDworph >> renderActive: props [

	| controller trigger teleport once world direction intersectionPoint |
	controller := self useControllerTransform.
	trigger := self useTriggerStrength.
	
	teleport := self useTeleport.
	once := self useRef: true.
	world := self useWorldPortal.
	
	direction := controller transform: 0 @ 0 @ 1.
	intersectionPoint := (GRRay origin: controller translation direction: direction)
		intersectPlane: 0 @ 0 @ 0
		normal: 0 @ 1 @ 0.
	
	self
		useEffect: [
			(trigger > 0.6 and: [once get and: [intersectionPoint notNil]]) ifTrue: [
				once set: false.
				teleport set: (Matrix4x4 withOffset: intersectionPoint)].
			trigger = 0 ifTrue: [once set: true]]
		dependencies: {trigger}.
	
	^ {
		self renderPassive: props.
		(self godot: #MeshInstance)
			mesh: ((self godot: #CubeMesh)
				size: 0.002 @ 0.002 @ 10.0;
				material: self material);
			translation: 0 @ 0 @ -5.
		intersectionPoint ifNotNil: [
			CMFReactNodePortal
				child: ((self godot: #MeshInstance)
					key: #pointer;
					mesh: ((self godot: #SphereMesh)
						material: self material;
						radius: 0.02;
						height: 0.04);
					translation: intersectionPoint)
				in: world]}
]

{ #category : #'as yet unclassified' }
TeleportToolDworph >> renderPassive: props [

	^ (self godot: #MeshInstance)
		mesh: ((self godot: #PrismMesh)
			size: 0.05 @ 0.07 @ 0.01;
			material: self material);
		rotation_degrees: 90 @ 180 @ 0
]
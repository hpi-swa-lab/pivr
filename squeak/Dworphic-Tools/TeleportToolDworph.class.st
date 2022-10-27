Class {
	#name : #TeleportToolDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Tools'
}

{ #category : #'as yet unclassified' }
TeleportToolDworph >> collisionShape [

	^ GDBoxShape new extents: 0.02 @ 0.005 @ 0.03
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
		passive: [(self methodAsComponent: #renderPassive:) props: props]
]

{ #category : #'as yet unclassified' }
TeleportToolDworph >> renderActive: props [

	| controller teleport world direction intersectionPoint |
	controller := self useControllerTransform.
	
	teleport := self useTeleport.
	world := self useWorldPortal.
	
	direction := controller transform: 0 @ 0 @ 1.
	intersectionPoint := (GRRay origin: controller translation direction: direction)
		intersectPlane: 0 @ 0 @ 0
		normal: 0 @ 1 @ 0.
	
	self useTriggerPressedDo: [intersectionPoint ifNotNil: [teleport set: (Matrix4x4 withOffset: intersectionPoint)]].
	
	^ {
		self renderPassive: props.
		GDMeshInstance new
			mesh: (GDCubeMesh new
				size: 0.002 @ 0.002 @ 10.0;
				material: self material);
			translation: 0 @ 0 @ -5.
		intersectionPoint ifNotNil: [
			CMFReactNodePortal
				child: (GDMeshInstance new
					key: #pointer;
					mesh: (GDSphereMesh new
						material: self material;
						radius: 0.02;
						height: 0.04);
					translation: intersectionPoint)
				in: world]}
]

{ #category : #'as yet unclassified' }
TeleportToolDworph >> renderPassive: props [

	^ GDMeshInstance new
		mesh: (GDPrismMesh new
			size: 0.05 @ 0.07 @ 0.01;
			material: self material);
		rotationDegrees: 90 @ 180 @ 0
]
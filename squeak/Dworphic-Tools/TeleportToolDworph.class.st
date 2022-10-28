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

	| grabbed transform world intersectionPoint |
	grabbed := self useState: false.
	transform := self useState: Matrix4x4 identity.
	
	world := self useWorldPortal.
	
	intersectionPoint := transform get forwardRay
		intersectPlane: 0 @ 0 @ 0
		normal: 0 @ 1 @ 0.
	
	^ GRGrabbableArea new
		onGrab: [grabbed set: true];
		onRelease: [grabbed set: false];
		onButtonPress: [:e |
			e isTrigger ifTrue: [
				intersectionPoint ifNotNil: ["TODO teleport to this transform"
				Matrix4x4 withOffset: intersectionPoint]]];
		children: {
			GDCollisionShape new
				shape: self collisionShape;
				children: (GDMeshInstance new
					mesh: (GDPrismMesh new
						size: 0.05 @ 0.07 @ 0.01;
						material: self material);
					rotationDegrees: 90 @ 180 @ 0).
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

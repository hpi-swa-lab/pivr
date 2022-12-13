Class {
	#name : #BlockCodeTool,
	#superclass : #GRComponent,
	#category : #'Dworphic-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeTool >> render: props [

	props extract: [:transform | | currentTransform overlappingAreas pointerArea worldPortal globalTransform holdingHand |
		currentTransform := self useState: Matrix4x4 identity.
		self useEffect: [currentTransform set: (transform ifNil: Matrix4x4 identity)] dependencies: #().
		pointerArea := self useGodotRef.
		
		overlappingAreas := self useState: #().
		globalTransform := self useState: Matrix4x4 new.
		worldPortal := self useWorldPortal.
		
		holdingHand := self useState: nil.
		
		^ GRDraggableArea new
			transform: currentTransform get;
			onGrab: [:event | holdingHand set: event handRef];
			onRelease: [:event |
				currentTransform set: event transform.
				holdingHand set: nil];
			"onButtonPress: [:event || directSpaceState raycastResult |
				event isTrigger ifTrue: [ | from to |
					from := globalTransform get translation.
					to :=  globalTransform get translation + (globalTransform get localDirToGlobal: 0 @ 1 @ 0).
					directSpaceState := pointerArea get getWorld directSpaceState.
					raycastResult := directSpaceState
						intersectRayFrom: from
						to: to
						exclude: {pointerArea get}
						collisionMask: CodeBlock blockLayer
						collideWithBodies: false
						collideWithAreas: true.
					Transcript showln: pointerArea get objectId asString, ' ', raycastResult]];"
			touch: true;
			point: false;
			children: {
				GDSpatial new
					subscribeTo: 'global_transform' do: [:t | globalTransform set: t].
				GDCollisionShape new
					shape: (GDCylinderShape new
						height: 20cm;
						radius: 1cm).
				GDMeshInstance new
					mesh: (GDCylinderMesh new
						height: 20cm;
						bottomRadius: 1cm;
						topRadius: 2mm).
				holdingHand get ifNotNil: [:ref |
					GRActingArea new
						point: true;
						touch: true;
						handRef: holdingHand;
						translation: 0 @ (0.5m + 10cm) @ 0;
						children: {
							GDCollisionShape new
								shape: (GDCylinderShape new
									height: 1m;
									radius: 3cm)}].
				"GDArea new
				ref: pointerArea;
				collisionMask: 0;
				collisionLayer: CodeBlock blockLayer;
				onAreaEntered: [:area | overlappingAreas set: [:old | old copyWith: area]];
				onAreaExited: [:area | overlappingAreas set: [:old | old copyWithout: area]];
				translation: 0 @ (0.5m + 10cm) @ 0;
				children: {
					GDCollisionShape new
						shape: (GDCylinderShape new
							height: 1m;
							radius: 3cm)}."
				GDMeshInstance new
					visible: overlappingAreas get notEmpty;
					translation: 0 @ (0.5m + 10cm) @ 0;
					mesh: (GDCylinderMesh new
						height: 1m;
						bottomRadius: 1mm;
						topRadius: 1mm;
						material: (GDSpatialMaterial new
							albedoColor: Color magenta))}]
]

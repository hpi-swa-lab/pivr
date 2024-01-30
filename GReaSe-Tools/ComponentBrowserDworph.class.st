Class {
	#name : #ComponentBrowserDworph,
	#superclass : #GRComponent,
	#category : #'GReaSe-Tools'
}

{ #category : #'as yet unclassified' }
ComponentBrowserDworph class >> appDescription [
	<home>

	^ super appDescription
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> fontSize [

	^ 30
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> render: props [

	| viewportTransform viewport spatial raycastPosStart raycastPosEnd world |
	world := self useWorldPortal.
	raycastPosStart := self useState: Vector3 new.
	raycastPosEnd := self useState: Vector3 new.
	viewportTransform := self useState: nil.
	viewport := self useGodotRef.
	spatial := self useGodotRef.
	
	^ GRViewportTexture new
		getViewport: [:vp | viewport set: vp];
		extent: self resolution;
		children: (GDControl new
			rectSize: self resolution;
			children: {
			GDButton new
				text: 'Test'.
				});
		meshDo: [:material |
			GRGrabbableArea new children: {
				GDCollisionShape new shape: (GDBoxShape new extents: 0.75 @ 0.5 @ 0.1); translation: 0 @ 1 @ -0.1 .
				GRInteractiveArea new
				touch: false;
				point: true;
					children: {
						GDSpatial new
							ref: spatial;
							subscribeTo: #global_transform do: [ :transform | viewportTransform set: transform].
						GDCollisionShape new shape: (GDBoxShape new extents: 0.75 @ 0.5 @ 0.001); translation: 0 @ 1 @ 0.001.
					};
					onButtonPress: [:event | 
						"Raycast from event-hand transform with distance of hand object to find intersection coordinate"
						| raycastResult |
						Transcript showln: '---New button event---'.
						raycastResult := spatial get getWorld directSpaceState
							intersectRayFrom: event transform translation
							to: (event transform localPointToGlobal: (0 @ 0 @ GRPointer laserLength negated))
							exclude: {}
							collisionMask: 2147483647
							collideWithBodies: true
							collideWithAreas: true.
						raycastPosStart set: event transform translation.
						raycastPosEnd set: (event transform localPointToGlobal: (0 @ 0 @ GRPointer laserLength negated)).
						Transcript showln: 'Raycast performed'.
						"Convert intersection coordinate to coordinate in viewport"
						raycastResult ifNotNil: [
							
							(raycastResult at: #position ifAbsent: nil) ifNotNil: [
							
							| viewportCoord3D viewportCoord2D inputEvent |
							Transcript showln: 'INTERSECTION FOUND'.
							raycastPosStart set: (viewportTransform get globalPointToLocal: (0@0@0)).
							raycastPosEnd set: (raycastResult at: #position).
							viewportCoord3D := viewportTransform get globalPointToLocal: (raycastResult at: #position).
							Transcript showln: 'Local space:'.
							Transcript showln: viewportCoord3D.
							viewportCoord2D := (((viewportCoord3D x / 1.5) + 0.5) * self resolution x  @ ((viewportCoord3D y / 1) + 0.5) * self resolution y ).
							Transcript showln: 'Inverse transform space:'.
							Transcript showln: viewportCoord2D.
							
							"Generate viewport click event"
							inputEvent := GDInputEventMouseButton new 
									buttonIndex: 1;
									pressed: true;
									position: viewportCoord2D;
									globalPosition: viewportCoord2D;
									buttonMask: 1.
									
							"@TODO find out why this does not work"
							"viewport get inputLocalEvent: inputEvent."
							]]
						].
				GDMeshInstance new
				translation: 0@1@0;
					mesh: (GDQuadMesh new
						 size: 1.5 @ 1;
						material: material).
				
				CMFReactNodePortal child: {AttentionDworph new target: raycastPosStart get} in: world.
				CMFReactNodePortal child: {AttentionDworph new target: raycastPosEnd get} in: world.
				
				}]
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> resolution [

	^ (1500 @ 1000)
]

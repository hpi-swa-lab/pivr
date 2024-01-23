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

	| viewportTransform viewport |
	viewportTransform := self useState: nil.
	viewport := self useGodotRef.
	
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
				GDCollisionShape new shape: (GDBoxShape new extents: 0.75 @ 0.5 @ 0.1); translation: 0 @ 1 @ 0.
				GRInteractiveArea new
					children: {
						GDCollisionShape new shape: (GDBoxShape new extents: 0.75 @ 0.5 @ 0.001); translation: 0 @ 1 @ 0.
					};
					subscribeTo: #global_transform do: [ :transform |
						viewportTransform set: transform.
						Transcript showln: transform.
						];
					onButtonPress: [:event | 
						"Raycast from event-hand transform with distance of hand object to find intersection coordinate"
						| raycastResult |
						raycastResult := event handRef getWorld directSpaceState
							intersectRayFrom: event transform translation
							to: (event transform localPointToGlobal: (GRPointer laserLength @ 0 @ 0)).
						"Convert intersection coordinate to coordinate in viewport"
						raycastResult ifNotNil: [
							| viewportCoord3D viewportCoord2D inputEvent|
							viewportCoord3D := viewportTransform xformInv: (raycastResult position).
							viewportCoord2D := (0 @ 0).
							
							"Generate viewport click event"
							inputEvent := GDInputEventMouseButton new 
									buttonIndex: 1;
									pressed: true;
									position: viewportCoord2D;
									globalPosition: viewportCoord2D;
									buttonMask: 1.
							viewport input: inputEvent.
							]
						].
				GDMeshInstance new
				translation: 0@1@0;
					mesh: (GDQuadMesh new
						size: 1.5 @ 1;
						material: material).
				GDMeshInstance new
					translation: 0 @ 1 @ 0;
					mesh: (GDQuadMesh new
						size: 1.5 @ 1;
						material: material);
					rotationDegrees: 0 @ 180 @ 0}]
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> resolution [

	^ (1500 @ 1000)
]

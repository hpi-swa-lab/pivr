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
ComponentBrowserDworph >> generateUIForFiber: aCMFFiber inTree: aGDTree withRoot: aGDTreeItem [

	| currentItem |
	
	aGDTreeItem ifNil: [currentItem := aGDTree createItem] ifNotNil: [currentItem := aGDTree createItemParent: aGDTreeItem].
	currentItem
		setTextColumn: 0 text: (aCMFFiber node asString copyWithRegex: '[\<\/\>]' matchesReplacedWith: '').

	^ {
		currentItem.
		aCMFFiber sibling ifNotNil: [self generateUIForFiber: aCMFFiber sibling inTree: aGDTree withRoot: aGDTreeItem].
		aCMFFiber child ifNotNil: [self generateUIForFiber: aCMFFiber child inTree: aGDTree withRoot: currentItem].
	}
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> hashTree: aCMFFiber [

	| sum |
	
	sum := 0.

	 ^ sum
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> render: props [

	| viewportTransform viewport spatial raycastPosStart raycastPosEnd world movingButton rootFiber treeRef |
	
	"---Only needed for debug---"
	world := self useWorldPortal.
	raycastPosStart := self useState: Vector3 new.
	raycastPosEnd := self useState: Vector3 new.
	movingButton := self useGodotRef.
	"---"
	viewportTransform := self useState: nil.
	viewport := self useGodotRef.
	spatial := self useGodotRef.
	rootFiber := (((GRReact current instVarNamed: #sessions) associations first value) instVarNamed: #react) currentRoot.
	treeRef := self useGodotRef.
	self useEffect: [
		treeRef get ifNotNil: [:tree | 
			tree clear.
			self generateUIForFiber: rootFiber inTree: tree withRoot: nil]]
	dependencies: {treeRef get ifNotNil: [:node | node objectId]. self hashTree: rootFiber }.
	
	^ GRViewportTexture new
		getViewport: [:vp | viewport set: vp];
		extent: self resolution;
		children: (GDControl new
			rectSize: self resolution;
			children: {
			GDTree new
			   ref: treeRef
				});
		meshDo: [:material |
			GRGrabbableArea new children: {
				GDCollisionShape new shape: (GDBoxShape new extents: 0.75 @ 0.5 @ 0.1); translation: 0 @ 0 @ -0.1 .
				GRInteractiveArea new
				touch: false;
				point: true;
					children: {
						GDSpatial new
							ref: spatial;
							subscribeTo: #global_transform do: [ :transform | viewportTransform set: transform].
						GDCollisionShape new shape: (GDBoxShape new extents: 0.75 @ 0.5 @ 0.001); translation: 0 @ 0 @ 0.001.
					};
					onButtonPress: [:event || raycastResult |
						"Raycast from event-hand transform with distance of hand object to find intersection coordinate"
						raycastResult := spatial get getWorld directSpaceState
							intersectRayFrom: event transform translation
							to: (event transform localPointToGlobal: (0 @ 0 @ GRPointer laserLength negated))
							exclude: {}
							collisionMask: 2147483647
							collideWithBodies: true
							collideWithAreas: true.
						raycastPosStart set: event transform translation.
						raycastPosEnd set: (event transform localPointToGlobal: (0 @ 0 @ GRPointer laserLength negated)).
						"Convert intersection coordinate to coordinate in viewport"
						raycastResult ifNotNil: [
							
							(raycastResult at: #position ifAbsent: nil) ifNotNil: [ |viewportCoord3D viewportCoord2D |
							raycastPosStart set: (viewportTransform get globalPointToLocal: (0@0@0)).
							raycastPosEnd set: (raycastResult at: #position).
							viewportCoord3D := viewportTransform get globalPointToLocal: (raycastResult at: #position).
							viewportCoord2D := Point
								x: ((viewportCoord3D x / 1.5) + 0.5) * self resolution x
								y: ((viewportCoord3D y negated/ 1) + 0.5) * self resolution y.
							
							"Generate viewport click event"
							GDInputEventMouseButton externalNewDuring: [ :mouseEvent |
								mouseEvent 
									buttonIndex: 1;
									pressed: true;
									position: viewportCoord2D;
									globalPosition: viewportCoord2D;
									buttonMask: 1.
									viewport get inputLocalEvent: mouseEvent.
								] .
							
							"movingButton get setPosition: viewportCoord2D.		"					]]
						];
					onButtonRelease: [:event || raycastResult |
						"Raycast from event-hand transform with distance of hand object to find intersection coordinate"
						raycastResult := spatial get getWorld directSpaceState
							intersectRayFrom: event transform translation
							to: (event transform localPointToGlobal: (0 @ 0 @ GRPointer laserLength negated))
							exclude: {}
							collisionMask: 2147483647
							collideWithBodies: true
							collideWithAreas: true.
						raycastPosStart set: event transform translation.
						raycastPosEnd set: (event transform localPointToGlobal: (0 @ 0 @ GRPointer laserLength negated)).
						"Convert intersection coordinate to coordinate in viewport"
						raycastResult ifNotNil: [
							
							(raycastResult at: #position ifAbsent: nil) ifNotNil: [ |viewportCoord3D viewportCoord2D |
							raycastPosStart set: (viewportTransform get globalPointToLocal: (0@0@0)).
							raycastPosEnd set: (raycastResult at: #position).
							viewportCoord3D := viewportTransform get globalPointToLocal: (raycastResult at: #position).
							viewportCoord2D := Point
								x: ((viewportCoord3D x / 1.5) + 0.5) * self resolution x
								y: ((viewportCoord3D y negated/ 1) + 0.5) * self resolution y.
							
							"Generate viewport click event"
							GDInputEventMouseButton externalNewDuring: [ :mouseEvent |
								mouseEvent 
									buttonIndex: 1;
									pressed: false;
									position: viewportCoord2D;
									globalPosition: viewportCoord2D;
									buttonMask: 1.
									viewport get inputLocalEvent: mouseEvent.
								] .
							
							"movingButton get setPosition: viewportCoord2D.		"					]]
						].
				GDMeshInstance new
				translation: 0@0@0;
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

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
ComponentBrowserDworph >> displayStateOfTreeNode: aTreeNode onItemList: anItemList [

	aTreeNode getSelected ifNotNil: [:treeItem |
		anItemList clear.
		anItemList addItemText: 'TEMPS'.
		(treeItem getMetaName: 'reactTemps') ifNotNil: [:temps | 
			temps do: [:tempString |
				anItemList addItemText: tempString.
			]
		].							
		anItemList addItemText: 'HOOKS'.
		(treeItem getMetaName: 'reactHooks') ifNotNil: [:hooks | 
			hooks do: [:hookString |
				anItemList addItemText: hookString.
			]
		].
		anItemList addItemText: 'PROPS'.
		(treeItem getMetaName: 'reactProps') ifNotNil: [:props | 
			props do: [:propString |
				anItemList addItemText: propString.
			]
		].
	]
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> fontSize [

	^ 30
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> generateUIForFiber: aCMFFiber inTree: aGDTree withRoot: aGDTreeItem [

	| currentItem |
	
	aGDTreeItem
		ifNil: [currentItem := aGDTree createItem]
		ifNotNil: [currentItem := aGDTree createItemParent: aGDTreeItem].
	[currentItem setTextColumn: 0 text: (aCMFFiber node asStringOrText)]
		ifError: [currentItem setTextColumn: 0 text: 'Parsing node failed'].
		
	currentItem setMetaName: 'reactTemps' value: (ComponentBrowser displayTempsForFiber: aCMFFiber).
	currentItem setMetaName: 'reactHooks' value: (ComponentBrowser displayHooksForFiber: aCMFFiber).
	currentItem setMetaName: 'reactProps' value: (ComponentBrowser displayPropsForFiber: aCMFFiber).

	^ {
		currentItem.
		aCMFFiber sibling ifNotNil: [self generateUIForFiber: aCMFFiber sibling inTree: aGDTree withRoot: aGDTreeItem].
		aCMFFiber child ifNotNil: [self generateUIForFiber: aCMFFiber child inTree: aGDTree withRoot: currentItem].
	}
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> hashFiber: aCMFFiber [

	| sum |
	
	"TODO Make use of Squeak's object ID system."
	sum := aCMFFiber index asInteger.
	aCMFFiber sibling ifNotNil: [sum := (sum asInteger) + ((self hashFiber: (aCMFFiber sibling)) asInteger)].
	aCMFFiber child ifNotNil: [sum := (sum asInteger) + ((self hashFiber: (aCMFFiber child)) asInteger)].

	 ^ sum
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> raycastMouseEvent: anEvent onSpatial: spatialRef forViewport: viewportRef withTransform: viewportTransform isMouseDown: down [
	"Raycast a mouse event on a 3D plane to a certain coordinate of a related 2D viewport and input such."
	
	| raycastResult |
		
	"Raycast from event-hand transform with distance of hand object to find intersection coordinate"
	raycastResult := spatialRef get getWorld directSpaceState
		intersectRayFrom: anEvent transform translation
		to: (anEvent transform localPointToGlobal: (0 @ 0 @ GRPointer laserLength negated))
		exclude: {}
		collisionMask: 2147483647
		collideWithBodies: true
		collideWithAreas: true.
		
	"Convert intersection coordinate to coordinate in viewport"
	raycastResult ifNotNil: [
		(raycastResult at: #position ifAbsent: nil) ifNotNil: [
			| viewportCoord3D viewportCoord2D |
		
			viewportCoord3D := viewportTransform get globalPointToLocal: (raycastResult at: #position).
			viewportCoord2D := Point
				x: ((viewportCoord3D x / 1.5) + 0.5) * self resolution x
				y: ((viewportCoord3D y negated/ 1) + 0.5) * self resolution y.
	
	"Generate viewport click event"
	GDInputEventMouseButton externalNewDuring: [ :mouseEvent |
		mouseEvent 
			buttonIndex: 1;
			pressed: down;
			position: viewportCoord2D;
			globalPosition: viewportCoord2D;
			buttonMask: 1.
			viewportRef get inputLocalEvent: mouseEvent.
		] .
	]]
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> render: props [

	| viewportTransform viewport spatial treeRef listRef |
	
	viewportTransform := self useState: nil.
	viewport := self useGodotRef.
	spatial := self useGodotRef.
	treeRef := self useGodotRef.
	listRef := self useGodotRef.
	
	self
		useEffect: [
			treeRef get ifNotNil: [:tree |
				tree clear.
				listRef get ifNotNil: [:listNode | listNode clear].
				self generateUIForFiber: (ComponentBrowser getCurrentRoot) inTree: tree withRoot: nil.
			]]
		dependencies: {treeRef get ifNotNil: [:node | node objectId]. self hashFiber: ComponentBrowser getCurrentRoot }.
	
	^ GRViewportTexture new
		getViewport: [:vp | viewport set: vp];
		extent: self resolution;
		children: (GDControl new
			rectSize: self resolution;
			children: {
			GDTree new
			   ref: treeRef;
				rectSize: (1000@1000);
				onItemSelected: [listRef get ifNotNil: [:listNode | 
					treeRef get ifNotNil: [:treeNode |
							self displayStateOfTreeNode: treeNode onItemList: listNode.
						]					
					]].
			GDItemList new
				ref: listRef;
				rectPosition: (1000@0);
				rectSize: (500@1000).
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
					onButtonPress: [:event |
							self raycastMouseEvent: event onSpatial: spatial forViewport: viewport withTransform: viewportTransform isMouseDown: true.
						];
					onButtonRelease: [:event |
							self raycastMouseEvent: event onSpatial: spatial forViewport: viewport withTransform: viewportTransform isMouseDown: false.
						].
				GDMeshInstance new
				translation: 0@0@0;
					mesh: (GDQuadMesh new
						 size: 1.5 @ 1;
						material: material).
				}]
]

{ #category : #'as yet unclassified' }
ComponentBrowserDworph >> resolution [

	^ (1500 @ 1000)
]

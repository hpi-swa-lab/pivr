Class {
	#name : #VirtualKeyboardDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> collisionShape [

	^ (self godot: #BoxShape) extents: 0.02 @ 0.005 @ 0.03
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> hoveredMaterial [

	^ (self godot: #SpatialMaterial) albedo_color: (Color r: 0.669 g: 0.669 b: 0.669)
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> keySize [

	^ 0.05
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> material [

	^ (self godot: #SpatialMaterial) albedo_color: (Color r: 0.37 g: 0.37 b: 0.37)
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> render: props [

	^ ControllerToolDworph new
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		shape: self collisionShape;
		onRelease: #return;
		active: [(self methodAsComponent: #renderActive:) props: props];
		passive: [(self methodAsComponent: #renderPassive:) props: props]
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> renderActive: props [

	| keyboardTransform head worldPortal pointerRef |
	keyboardTransform := self useState: Matrix4x4 identity.
	head := self useProvidedRef: #headTransform.
	worldPortal := self useWorldPortal.
	pointerRef := self useRemoteRef.
	
	self
		useEffect: ["FIXME: doesnt seem quite right yet. and also not very convenient."
		keyboardTransform set: (Matrix4x4 withRotation: head get rotation second negated around: 0 @ 1 @ 0) * (Matrix4x4 withOffset: 0 @ 0.1 @ -1)]
		dependencies: {}.
	
	^ {
		self renderPassive: props.
		(self godot: #Area)
			children: {
				(self godot: #MeshInstance)
					mesh: ((self godot: #CubeMesh)
						size: 0.002 @ 0.002 @ 10.0;
						material: self material);
					translation: 0 @ 0 @ -5.
				(self godot: #CollisionShape) shape: ((self godot: #RayShape) length: -10.0)};
			ref: pointerRef.
		CMFReactNodePortal
			child: ((self methodAsComponent: #renderKeyboard:)
				transform: keyboardTransform get;
				pointer: pointerRef get)
			in: worldPortal}
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> renderKey: props [

	| areaAndHovered |
	areaAndHovered := self
		useAreaWithIntersectionFor: [:node | node = (props at: #pointer)]
		dependencies: {(props at: #pointer) ifNotNil: #objectId}.
	
	^ {
		areaAndHovered second ifTrue: [
			"only subscribe to trigger events if we are currently hovered"
			[:nestedProps |
				self useTriggerPressedDo: [(props at: #onPressed) value].
				nil] asComponent].
		areaAndHovered first
			children: {
				(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh)
					size: self keySize asPoint @ 0.02;
					material: (areaAndHovered second ifTrue: [self hoveredMaterial] ifFalse: [self material])).
				(self godot: #Label3D)
					translation: 0 @ 0 @ 0.011;
					text: (props at: #letter) asString;
					pixel_size: 0.001;
					font: ((self godot: #DynamicFont)
						font_data: ((self godot: #DynamicFontData) font_path: 'res://TSText/DejaVuSans.ttf');
						size: 32).
				(self godot: #CollisionShape) shape: ((self godot: #BoxShape) extents: self keySize asPoint / 2 @ 0.01)};
			translation: (props at: #position) @ 0 * self keySize}
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> renderKeyboard: props [

	| layout readyForNextLetter |
	layout := {'1234567890'. 'qwertzuiop'. 'asdfghjkl'. 'yxcvbnm'}.
	
	readyForNextLetter := self useState: true.
	self useTriggerReleasedDo: [readyForNextLetter set: true].
	
	^ (self godot: #MeshInstance)
		transform: (props at: #transform);
		mesh: ((self godot: #CubeMesh)
			size: (layout collect: #size) max * self keySize @ 0.3 @ 0.01;
			material: self material);
		children: {
			(self godot: #Spatial)
				translation: (layout collect: #size) max - 1 * self keySize / -2 @ (self keySize * -1.5) @ 0;
				children: (layout withIndexCollect: [:row :rowIndex |
					row asOrderedCollection withIndexCollect: [:letter :columnIndex |
						(self methodAsComponent: #renderKey:)
							key: letter;
							letter: letter;
							pointer: (props at: #pointer);
							position: columnIndex - 1 @ (layout size - (rowIndex - 1));
							onPressed: [
								readyForNextLetter get ifTrue: [
									Transcript showln: letter.
									readyForNextLetter set: false]]]])}
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> renderPassive: props [

	^ (self godot: #MeshInstance)
		mesh: ((self godot: #PrismMesh)
			size: 0.05 @ 0.07 @ 0.01;
			material: self material);
		rotation_degrees: 90 @ 180 @ 0
]

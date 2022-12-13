Class {
	#name : #CodeBlock,
	#superclass : #GRComponent,
	#category : #'Dworphic-BlockCode'
}

{ #category : #'as yet unclassified' }
CodeBlock class >> blockLayer [

	^ 1 bitShift: 28
]

{ #category : #'as yet unclassified' }
CodeBlock >> computeDefaultTransform [

	^ Matrix4x4 identity
]

{ #category : #'as yet unclassified' }
CodeBlock >> computeTranslationFrom: layoutParams block: aBlock [

	| parent adjustedPosition |
	parent := aBlock owner.
	
	adjustedPosition := aBlock topLeft - parent topLeft + (aBlock extent - parent extent / 2) * layoutParams morphicScale.
	adjustedPosition := adjustedPosition x @ (adjustedPosition y * -1).
	
	^ adjustedPosition @ layoutParams blockDepth
]

{ #category : #'as yet unclassified' }
CodeBlock >> render: props [

	^ ((props at: #sandblock) isUnknown
		ifTrue: [self methodAsComponent: #renderUnknown:]
		ifFalse: [self methodAsComponent: #renderBlock:])
		props: props
]

{ #category : #'as yet unclassified' }
CodeBlock >> renderBlock: props [

	props extract: [:sandblock :layoutParams :translation | | do editorTransform isHovered scale overlappingDropAreas draggedSandblock setDraggedSandblock insertPositions getDropAreaCommandConstructor childLayoutParams globalTransform |
		scale := self scale: props.
		
		globalTransform := self useState: Matrix4x4 identity.
		childLayoutParams := sandblock floating
			ifTrue: [
				layoutParams copy
					rootGlobalTransform: globalTransform get;
					rootGlobalExtent: (scale x @ scale y) / 2]
			ifFalse: [layoutParams].
		
		isHovered := self useState: false.
		do := self useProvided: #doSandblocksCommand.
		editorTransform := self useProvided: #editorTransform.
		
		overlappingDropAreas := self useState: #().
		getDropAreaCommandConstructor := self useProvided: #getDropAreaCommandConstructor.
		draggedSandblock := self useProvided: #draggedSandblock.
		setDraggedSandblock := self useProvided: #setDraggedSandblock.

		insertPositions := (draggedSandblock isNil or: [draggedSandblock = sandblock] or: [draggedSandblock isMethod])
			ifTrue: [#()]
			ifFalse: [
				Array streamContents: [:stream |
					sandblock cursorPositionsDo: [:pos |
						(sandblock = pos block) ifTrue: [
							(pos isInsert and: [pos container isTSBlock]) ifTrue: [ | targetType bounds parentBounds |
								targetType := pos command element.
								bounds := pos bounds.
								parentBounds := sandblock bounds.
								((draggedSandblock adaptSlotFor: (SBTSSlot with: targetType) ifFailed: [nil]) ifNotNil: [:adaptedCopy |
									pos command morphs: {adaptedCopy}.
									stream nextPut: ((self methodAsComponent: #renderInsertArea:)
										pos: pos;
										translation: (bounds center - parentBounds center) asVector3 * layoutParams morphicScale * (1 @ -1 @ 1);
										scale: (bounds width * layoutParams morphicScale) @ (bounds height * layoutParams morphicScale) @ 10cm)])]]]]].
		
		^ GRDraggableArea new
			releaseCondition: #containerUnmount;
			handle: sandblock;
			transform: (sandblock floating
				ifTrue: [sandblock valueOfProperty: #vrTransform ifAbsentPut: [self computeDefaultTransform]]
				ifFalse: [Matrix4x4 withOffset: (self computeTranslationFrom: layoutParams block: sandblock)]);
			onHover: [isHovered set: true];
			onBlur: [isHovered set: false];
			onButtonPress: [:e | e isTrigger ifTrue: [sandblock select]];
			onGrab: [
				setDraggedSandblock value: sandblock.
				do value: (SBCombinedCommand newWith: {
					sandblock parentSandblock deleteCommandFor: sandblock.
					sandblock sandblockEditor insertCommandRequest: sandblock near: nil before: false})];
			onRelease: [:event | 
				setDraggedSandblock value: nil.
				(overlappingDropAreas get
					collect: [:area | getDropAreaCommandConstructor value: area]
					thenSelect: #notNil)
					ifEmpty: [
						sandblock setProperty: #vrTransform toValue: event transform]
					ifNotEmpty: [:commandConstructors | | constructor |
						constructor := commandConstructors first.
						do value: (constructor cull: sandblock)]];
			children: {
				sandblock floating ifTrue: [
					GDSpatial new
						subscribeTo: 'global_transform' do: [:t | globalTransform set: t]].
				GDCollisionShape new
					scale: scale;
					shape: (GDBoxShape new extents: 0.5 asVector3).
				GDArea new
					collisionMask: (GRDropArea dropLayer bitOr: CodeBlock blockLayer);
					collisionLayer: CodeBlock blockLayer;
					onAreaEntered: [:area | overlappingDropAreas set: [:old | old copyWith: area]];
					onAreaExited: [:area | overlappingDropAreas set: [:old | old copyWithout: area]];
					children: {
						GDCollisionShape new
							scale: scale;
							shape: (GDBoxShape new extents: 0.5 asVector3)}.
				GDMeshInstance new
					scale: scale;
					mesh: (GDCubeMesh new
						size: (Vector3 value: 1);
						material: (GDSpatialMaterial new albedoColor: (isHovered get ifTrue: [Color green] ifFalse: [Color white])))}, (sandblock childrenAsCodeBlocks do: [:b | b layoutParams: childLayoutParams]), insertPositions]
]

{ #category : #'as yet unclassified' }
CodeBlock >> renderInsertArea: props [

	props extract: [:pos :layoutParams :translation :scale | | areaRef registerDropArea unregisterDropArea | 
		registerDropArea := self useProvided: #registerDropArea.
		unregisterDropArea := self useProvided: #unregisterDropArea.
		areaRef := self useGodotRef.
		self useEffect: [
			registerDropArea value: areaRef value: [pos command].
			[unregisterDropArea value: areaRef]]
			dependencies: {pos command}.
		
		^ GDArea new
			ref: areaRef;
			translation: translation;
			scale: scale;
			collisionMask: 0;
			collisionLayer: GRDropArea dropLayer;
			children: {self cubeOfSize: 1 color: Color red}]
]

{ #category : #'as yet unclassified' }
CodeBlock >> renderPopoutArea: props [

	| offset translation radius coneDiameterAndHeight |
	translation := props at: #translation.
	offset := 5cm.
	radius := 2cm.

	coneDiameterAndHeight := self useMemo: [ | coneAngle coneDiameter coneHeight coneSideLength |
		coneSideLength := (offset squared - radius squared) sqrt.
		coneAngle := (radius / offset) arcSin * 2.
		coneDiameter := (2 * coneSideLength squared * (1 - (coneAngle cos))) sqrt.
		coneHeight := (coneSideLength squared - (coneDiameter squared / 4)) sqrt.
		{coneDiameter. coneHeight}]
		dependencies: #(offset radius).
	
	^ {
		(self sphereOfRadius: radius color: Color lightBlue)
			translation: translation + (0 @ 0 @ offset).
		GDMeshInstance new
			mesh: (GDCylinderMesh new
				bottomRadius: 0;
				topRadius: coneDiameterAndHeight first / 2;
				height: coneDiameterAndHeight second;
				material: (GDSpatialMaterial new
					albedoColor: Color lightBlue));
			rotation: Float pi / 2 @ 0 @ 0;
			translation: translation + (0 @ 0 @ (coneDiameterAndHeight second / 2))}
]

{ #category : #'as yet unclassified' }
CodeBlock >> renderUnknown: props [

	props extract: [:sandblock :layoutParams | | areaRef registerDropArea unregisterDropArea translation | 
		registerDropArea := self useProvided: #registerDropArea.
		unregisterDropArea := self useProvided: #unregisterDropArea.
		areaRef := self useGodotRef.
		self useEffect: [
			registerDropArea value: areaRef value: [:insertedSandblock |
				SBCombinedCommand newWith: {
					insertedSandblock parentSandblock deleteCommandFor: insertedSandblock.
					SBReplaceCommand new
						target: sandblock
						replacer: (insertedSandblock copyBlock adaptSlotFor: sandblock slot)}].
			[unregisterDropArea value: areaRef]]
			dependencies: {sandblock}.

		translation := self computeTranslationFrom: layoutParams block: sandblock.		
		
		^ GDArea new
			ref: areaRef;
			collisionMask: 0;
			collisionLayer: GRDropArea dropLayer;
			children: {
				(self cubeOfSize: 1 color: Color blue)
					scale: (self scale: props);
					translation: translation.
				(self methodAsComponent: #renderPopoutArea:)
					translation: translation}]
]

{ #category : #'as yet unclassified' }
CodeBlock >> scale: props [

	| morphBounds layoutParams sandblock |
	layoutParams := props at: #layoutParams.
	morphBounds := (props at: #sandblock) bounds.
	sandblock := (props at: #sandblock).
	^ Vector3
		x: sandblock width * layoutParams morphicScale
		y: sandblock height * layoutParams morphicScale
		z: layoutParams blockDepth
]

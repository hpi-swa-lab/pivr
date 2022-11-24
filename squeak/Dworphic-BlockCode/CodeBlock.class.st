Class {
	#name : #CodeBlock,
	#superclass : #GRComponent,
	#category : #'Dworphic-BlockCode'
}

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

	props extract: [:sandblock :layoutParams :translation | | do editorTransform isHovered scale overlappingDropAreas getDropAreaSandblock |
		scale := self scale: props.
		
		isHovered := self useState: false.
		do := self useProvided: #doSandblocksCommand.
		editorTransform := self useProvided: #editorTransform.
		
		overlappingDropAreas := self useState: #().
		getDropAreaSandblock := self useProvided: #getDropAreaSandblock.
		
		^ GRDraggableArea new
			releaseCondition: #containerUnmount;
			handle: sandblock;
			transform: (sandblock floating
				ifTrue: [sandblock valueOfProperty: #vrTransform ifAbsentPut: [self computeDefaultTransform]]
				ifFalse: [Matrix4x4 withOffset: (self computeTranslationFrom: layoutParams block: sandblock)]);
			onHover: [isHovered set: true];
			onBlur: [isHovered set: false];
			onGrab: [
				do value: (SBCombinedCommand newWith: {
					sandblock parentSandblock deleteCommandFor: sandblock.
					sandblock sandblockEditor insertCommandRequest: sandblock near: nil before: false})];
			onRelease: [:event | | localTransform inserted |
				inserted := false.
				(overlappingDropAreas get
					collect: [:area | getDropAreaSandblock value: area]
					thenSelect: #notNil)
					ifNotEmpty: [:otherSandblocks | | otherSandblock |
						otherSandblock := otherSandblocks first.
						(sandblock copyBlock adaptSlotFor: otherSandblock slot ifFailed: [nil]) ifNotNil: [:newBlock |
						do value: (SBCombinedCommand newWith: {
							sandblock parentSandblock deleteCommandFor: sandblock.
							SBReplaceCommand new
								target: otherSandblock
								replacer: newBlock}).
						inserted := true]].
				inserted ifFalse: [
					localTransform := editorTransform value inverseTransformation * event transform.
					sandblock setProperty: #vrTransform toValue: localTransform]];
			children: {
				GDCollisionShape new
					scale: scale;
					shape: (GDBoxShape new extents: 0.5 asVector3).
				GDArea new
					collisionMask: GRDropArea dropLayer;
					collisionLayer: 0;
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
						material: (GDSpatialMaterial new albedoColor: (isHovered get ifTrue: [Color green] ifFalse: [Color white])))}, (sandblock childrenAsCodeBlocks do: [:b | b layoutParams: layoutParams])]
]

{ #category : #'as yet unclassified' }
CodeBlock >> renderUnknown: props [

	props extract: [:sandblock :layoutParams :translation | | areaRef registerDropArea unregisterDropArea | 
		registerDropArea := self useProvided: #registerDropArea.
		unregisterDropArea := self useProvided: #unregisterDropArea.
		areaRef := self useGodotRef.
		self useEffect: [
			registerDropArea value: areaRef value: sandblock.
			[unregisterDropArea value: areaRef]]
			dependencies: {sandblock}.
		
		^ GDArea new
			ref: areaRef;
			collisionMask: 0;
			collisionLayer: GRDropArea dropLayer;
			children: {
				(self cubeOfSize: 1 color: Color blue)
					scale: (self scale: props);
					translation: (self computeTranslationFrom: layoutParams block: sandblock)}]
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

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

	props extract: [:sandblock :layoutParams :translation | | scale isHovered do editorTransform |
		scale := self scale: props.
		
		isHovered := self useState: false.
		do := self useProvided: #doSandblocksCommand.
		editorTransform := self useProvided: #editorTransform.
		
		^ GRDraggableArea new
			releaseCondition: #containerUnmount;
			handle: sandblock;
			transform: (sandblock floating
				ifTrue: [sandblock valueOfProperty: #vrTransform ifAbsentPut: [self computeDefaultTransform]]
				ifFalse: [Matrix4x4 withOffset: (self computeTranslationFrom: layoutParams block: sandblock)]);
			onHover: [isHovered set: true];
			onBlur: [isHovered set: false];
			onDragBegin: [
				Transcript showln: 'drag begin ', sandblock identityHash.
				do value: (SBCombinedCommand newWith: {
					sandblock parentSandblock deleteCommandFor: sandblock.
					sandblock sandblockEditor insertCommandRequest: sandblock near: nil before: false})];
			onDragEnd: [:event :otherSandblock | | localTransform |
				Transcript showln: 'drag end ', sandblock identityHash, '; otherSandblock ', otherSandblock identityHash.
				otherSandblock
					ifNil: [
						"just leave me floating"
						localTransform := editorTransform value inverseTransformation * event transform.
						sandblock setProperty: #vrTransform toValue: localTransform]
					ifNotNil: [
						do value: (SBCombinedCommand newWith: {
							sandblock parentSandblock deleteCommandFor: sandblock.
							SBReplaceCommand new
								target: otherSandblock
								replacer: (sandblock "copyBlock adaptSlotFor: otherSandblock slot")})]];
			children: {
				GDCollisionShape new
					scale: scale;
					shape: (GDBoxShape new extents: 0.5 asVector3).
				GDMeshInstance new
					scale: scale;
					mesh: (GDCubeMesh new
						size: (Vector3 value: 1);
						material: (GDSpatialMaterial new albedoColor: (isHovered get ifTrue: [Color green] ifFalse: [Color white])))}, (sandblock childrenAsCodeBlocks do: [:b | b layoutParams: layoutParams])]
]

{ #category : #'as yet unclassified' }
CodeBlock >> renderUnknown: props [

	props extract: [:sandblock :layoutParams :translation | | scale isHovered do editorTransform |
		scale := self scale: props.
		
		isHovered := self useState: false.
		do := self useProvided: #doSandblocksCommand.
		editorTransform := self useProvided: #editorTransform.
		
		^ GRDropArea new
			info: sandblock;
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

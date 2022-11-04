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

	props extract: [:sandblock :layoutParams :translation | | scale isHovered do |
		scale := self scale: props.
		
		isHovered := self useState: false.
		do := self useProvided: #doSandblocksCommand.
		
		^ GRDraggableArea new
			handle: sandblock;
			transform: (sandblock floating
				ifTrue: [sandblock valueOfProperty: #vrTransform ifAbsentPut: [self computeDefaultTransform]]
				ifFalse: [Matrix4x4 withOffset: (self computeTranslationFrom: layoutParams block: sandblock)]);
			onHover: ["name: (self class asString), GRReact nextGodotId asString;"
			isHovered set: true];
			onBlur: [isHovered set: false];
			onDragBegin: [
				do value: (SBCombinedCommand newWith: {
					sandblock parentSandblock deleteCommandFor: sandblock.
					sandblock sandblockEditor insertCommandRequest: sandblock near: nil before: false})];
			onDragEnd: [:event | sandblock setProperty: #vrTransform toValue: event transform];
			children: {
				GDCollisionShape new
					scale: scale;
					shape: (GDBoxShape new extents: 0.5 asVector3).
				GDMeshInstance new
					scale: scale;
					mesh: (GDCubeMesh new
						size: (Vector3 value: 1);
						material: (GDSpatialMaterial new albedoColor: (isHovered get ifTrue: [Color r: 0.0 g: 1 b: 0.0] ifFalse: [Color r: 1 g: 1 b: 1])))}, (sandblock childrenAsCodeBlocks do: [:b | b layoutParams: layoutParams])]
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

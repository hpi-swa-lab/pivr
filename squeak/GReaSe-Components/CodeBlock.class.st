Class {
	#name : #CodeBlock,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
CodeBlock >> childBlocks: props [

	| myStructure |
	myStructure := (props at: #structure).
	^ myStructure children
		ifNil: [#()]
		ifNotNil: [:children |
			children
				select: [:structure | | childClass |
					childClass := (structure at: #class).
					childClass = 'block' or: [childClass = 'text']]
				thenCollect: [:structure | | newClass |
					newClass := (structure at: #class) caseOf: {
						['block'] -> [CodeBlock].
						['text'] -> [CodeBlockText]}.
					
					newClass asReactNodeBuilder
						props: {
							#key -> GRReact nextGodotId.
							#structure -> structure.
							#parentStructure -> myStructure.
							#layoutParams -> (props at: #layoutParams)};
						build]].
]

{ #category : #'as yet unclassified' }
CodeBlock >> render: props [

	^ (self godot: #Spatial)
		name: (self class asString), GRReact nextGodotId asString;
		translation: (self translation: props);
		children: {
			(self godot: #MeshInstance)
				scale: (self scale: props);
				mesh: ((self godot: #CubeMesh)
					size: (Vector3 value: 1);
					material: ((self godot: #SpatialMaterial) albedo_color: Color random))
				}, (self childBlocks: props)
]

{ #category : #'as yet unclassified' }
CodeBlock >> scale: props [

	| morphBounds layoutParams |
	layoutParams := props at: #layoutParams.
	morphBounds := (props at: #structure) bounds.
	^ Vector3
		x: (morphBounds at: 3) * layoutParams morphicScale
		y: (morphBounds at: 4) * layoutParams morphicScale
		z: layoutParams blockDepth
]

{ #category : #'as yet unclassified' }
CodeBlock >> translation: props [

	| layoutParams |
	layoutParams := props at: #layoutParams.
	
	^ (props at: #isRoot ifAbsent: false)
		ifTrue: [Vector3 value: 0]
		ifFalse: [ | morphBounds parentBounds adjustedPosition morphExtent morphPosition parentExtent parentPosition |
			morphBounds := (props at: #structure) bounds.
			parentBounds := (props at: #parentStructure) bounds.
			morphPosition := morphBounds first @ morphBounds second.
			morphExtent := morphBounds third @ morphBounds fourth.
			parentPosition := parentBounds first @ parentBounds second.
			parentExtent := parentBounds third @ parentBounds fourth.
			
			adjustedPosition := (morphPosition - parentPosition + ((morphExtent - parentExtent) / 2)) * layoutParams morphicScale.
			adjustedPosition := adjustedPosition x  @ (adjustedPosition y * -1).
			
			adjustedPosition @ layoutParams blockDepth]
]

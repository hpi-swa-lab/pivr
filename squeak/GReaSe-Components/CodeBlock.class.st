Class {
	#name : #CodeBlock,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
CodeBlock >> childBlocks: props [

	^ Array streamContents: [:stream | | sandblock |
		sandblock := (props at: #sandblock).
		sandblock class = SBTSStMethod
			ifTrue: [
				sandblock visibleSubmorphsDo: [:morph |
					stream nextPut: (
						CodeBlock new
							key: GRReact nextGodotId;
							sandblock: morph;
							layoutParams: (props at: #layoutParams))]]
			ifFalse: [
				sandblock cursorPositionsDo: [:pos |
					(pos isSelect and: [pos block ~= sandblock]) ifTrue: [
						stream nextPut: (
							CodeBlock new
								key: GRReact nextGodotId;
								sandblock: pos block;
								layoutParams: (props at: #layoutParams))]]
					shallow: true]]
	"myStructure := (props at: #structure).
	^ (myStructure at: #children)
		ifNil: [#()]
		ifNotNil: [:children |
			children
				select: [:structure | #(block text) includes: (structure at: #class)]
				thenCollect: [:structure | | childClass |
					childClass := (structure at: #class) caseOf: {
						['block'] -> [CodeBlock].
						['text'] -> [CodeBlockText]}.
					
					childClass new
						key: GRReact nextGodotId;
						structure: structure;
						parentStructure: myStructure;
						layoutParams: (props at: #layoutParams)]]."
]

{ #category : #'as yet unclassified' }
CodeBlock >> render: props [

	^ GDSpatial new
		name: (self class asString), GRReact nextGodotId asString;
		translation: (self translation: props);
		children: {
			GDMeshInstance new
				scale: (self scale: props);
				mesh: ((self godot: #CubeMesh)
					size: (Vector3 value: 1);
					material: ((self godot: #SpatialMaterial) albedo_color: Color random))
				}, (self childBlocks: props)
]

{ #category : #'as yet unclassified' }
CodeBlock >> scale: props [

	| morphBounds layoutParams sandblock |
	layoutParams := props at: #layoutParams.
	"morphBounds := (props at: #structure) at: #bounds."
	"^ Vector3
		x: (morphBounds at: 3) * layoutParams morphicScale
		y: (morphBounds at: 4) * layoutParams morphicScale
		z: layoutParams blockDepth"
	morphBounds := (props at: #sandblock) bounds.
	sandblock := (props at: #sandblock).
	^ Vector3
		x: sandblock width * layoutParams morphicScale
		y: sandblock height * layoutParams morphicScale
		z: layoutParams blockDepth
]

{ #category : #'as yet unclassified' }
CodeBlock >> translation: props [

	| layoutParams |
	layoutParams := props at: #layoutParams.
	
	^ (props at: #isRoot ifAbsent: false)
		ifTrue: [Vector3 value: 0]
		ifFalse: [ | adjustedPosition morph parent |
			"morphBounds := (props at: #structure) at: #bounds.
			parentBounds := (props at: #parentStructure) at: #bounds.
			morphPosition := morphBounds first @ morphBounds second.
			morphExtent := morphBounds third @ morphBounds fourth.
			parentPosition := parentBounds first @ parentBounds second.
			parentExtent := parentBounds third @ parentBounds fourth."
			morph := props at: #sandblock.
			parent := morph owner.
			
			adjustedPosition := (morph topLeft - parent topLeft + ((morph extent - parent extent) / 2)) * layoutParams morphicScale.
			adjustedPosition := adjustedPosition x  @ (adjustedPosition y * -1).
			
			adjustedPosition @ layoutParams blockDepth]
]

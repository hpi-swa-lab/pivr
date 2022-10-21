Class {
	#name : #CodeBlock,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
CodeBlock >> childBlocks: props [

	^ Array streamContents: [:stream | | sandblock |
		sandblock := (props at: #sandblock).
		
		"TODO: move CodeBlock instantiation into respective classes"
		sandblock class = SBTSStMethod ifTrue: [
			sandblock visibleSubmorphsDo: [:morph |
				stream nextPut: (
					CodeBlock new
						key: GRReact nextGodotId;
						sandblock: morph;
						layoutParams: (props at: #layoutParams))]].
				
		(sandblock isKindOf: SBTSBlock) ifTrue: [
			sandblock cursorPositionsDo: [:pos |
				pos isText ifTrue: [
					stream nextPut: (
						CodeBlockText new
							key: GRReact nextGodotId;
							morph: pos textMorph;
							layoutParams: (props at: #layoutParams))].
				
				(pos isSelect and: [pos block ~= sandblock]) ifTrue: [
					stream nextPut: (
						CodeBlock new
							key: GRReact nextGodotId;
							sandblock: pos block;
							layoutParams: (props at: #layoutParams))]]
				shallow: true]]
]

{ #category : #'as yet unclassified' }
CodeBlock >> render: props [

	^ GDSpatial new
		name: (self class asString), GRReact nextGodotId asString;
		translation: (self translation: props);
		children: {
			GDMeshInstance new
				scale: (self scale: props);
				mesh: (GDCubeMesh new
					size: (Vector3 value: 1);
					material: (GDSpatialMaterial new albedoColor: Color random))
				}, (self childBlocks: props)
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

{ #category : #'as yet unclassified' }
CodeBlock >> translation: props [

	| layoutParams |
	layoutParams := props at: #layoutParams.
	
	^ (props at: #isRoot ifAbsent: false)
		ifTrue: [Vector3 value: 0]
		ifFalse: [ | adjustedPosition morph parent |
			morph := props at: #sandblock.
			parent := morph owner.
			
			adjustedPosition := (morph topLeft - parent topLeft + ((morph extent - parent extent) / 2)) * layoutParams morphicScale.
			adjustedPosition := adjustedPosition x  @ (adjustedPosition y * -1).
			
			adjustedPosition @ layoutParams blockDepth]
]

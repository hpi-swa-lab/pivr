Class {
	#name : #CodeBlock,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
CodeBlock >> render: props [

	| layoutParams |
	layoutParams := props at: #layoutParams.
	
	^ GDSpatial new
		name: (self class asString), GRReact nextGodotId asString;
		translation: (self translation: props);
		children: {
			GDMeshInstance new
				scale: (self scale: props);
				mesh: (GDCubeMesh new
					size: (Vector3 value: 1);
					material: (GDSpatialMaterial new albedoColor: Color random))},
			((props at: #sandblock) childrenAsCodeBlocks do: [:b |
				b layoutParams: layoutParams])
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

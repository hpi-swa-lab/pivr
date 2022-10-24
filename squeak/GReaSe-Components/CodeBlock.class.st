Class {
	#name : #CodeBlock,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
CodeBlock >> render: props [

	| layoutParams scale isHovered |
	layoutParams := props at: #layoutParams.
	scale := self scale: props.
	
	isHovered := self useState: false.
	
	^ GRInteractiveArea new
		"name: (self class asString), GRReact nextGodotId asString;"
		translation: (self translation: props);
		onHover: [isHovered set: true];
		onBlur: [isHovered set: false];
		"onButtonPress: [
			Project current addDeferredUIMessage: [
				(props at: #sandblock) sandblockEditor do: nil]];"
		children: {
			GDCollisionShape new
				scale: scale;
				shape: (GDBoxShape new
					extents: 0.5 asVector3).
			GDMeshInstance new
				scale: scale;
				mesh: (GDCubeMesh new
					size: (Vector3 value: 1);
					material: (GDSpatialMaterial new albedoColor: (isHovered get ifTrue: [Color green] ifFalse: [Color white])))},
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

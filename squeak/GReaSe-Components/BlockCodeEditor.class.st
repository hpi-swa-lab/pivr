Class {
	#name : #BlockCodeEditor,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeEditor >> blocks: props [

	^ ((props at: #structure) children) collect: [:structure |
		CodeBlock asReactNodeBuilder
			props: {
				#key -> GRReact nextGodotId.
				#structure -> structure.
				#layoutParams -> (props at: #layoutParams).
				#isRoot -> true};
			 build]
]

{ #category : #'as yet unclassified' }
BlockCodeEditor >> render: props [

	^ (self godot: #Spatial)
		translation: (props at: #translation ifAbsent: [Vector3 value: 0]);
		children: (self blocks: props)
]

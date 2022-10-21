Class {
	#name : #BlockCodeEditor,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeEditor >> blocks: props [

	^ ((props at: #structure) at: #children) collect: [:structure |
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

	| editor blocks |
	editor := self useRef: SBEditor new.
	
	blocks := self useState: {}.
	
	self useEffect: [ | block |
		editor get openInWindow.
		
		"for testing purposes"
		block := (SBTSStMethod for: Dictionary>>#associationsDo:).
		editor get openMorph: block.
		blocks set: [:old | old copyWith: block].
		
		[editor get delete]] dependencies: #().

	^ (self godot: #Spatial)
		translation: (props at: #translation ifAbsent: [Vector3 value: 0]);
		children: (blocks get collect: [:block |
			CodeBlock new
				key: GRReact nextGodotId;
				structure: block exportStructure;
				layoutParams: (props at: #layoutParams);
				isRoot: true])
]

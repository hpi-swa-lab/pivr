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

	| editor blocks forceUpdate |
	editor := self useRef: SBEditor new.
	blocks := self useState: {}.
	forceUpdate := self useForceUpdate.
	
	self useEffect: [ | block |
		editor get openInWindow.
		
		"for testing purposes"
		block := (SBTSStMethod for: Dictionary>>#associationsDo:).
		editor get openMorph: block.
		World doOneCycle.
		forceUpdate value.
				
		[editor get delete]] dependencies: #().

	^ (self godot: #Spatial)
		translation: (props at: #translation ifAbsent: [Vector3 value: 0]);
		children: (Array streamContents: [:stream |
			editor get childSandblocksDo: [:sandblock |
				stream nextPut: (CodeBlock new
					key: GRReact nextGodotId;
					sandblock: sandblock;
					layoutParams: (props at: #layoutParams);
					isRoot: true)]])
]

{ #category : #'as yet unclassified' }
BlockCodeEditor >> useForceUpdate [

	| n |
	n := self useState: 0.
	^ [n set: [:old | old + 1]]
]

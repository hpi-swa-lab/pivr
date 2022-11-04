Class {
	#name : #BlockCodeEditor,
	#superclass : #GRComponent,
	#category : #'Dworphic-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeEditor class >> appDescription [
	<home>

	^ DworphicApplicationDescription new
		name: self name;
		render: [self new
			layoutParams: (CodeBlockLayoutParamters new
				blockDepth: 0.01;
				morphicScale: 0.003)]
]

{ #category : #'as yet unclassified' }
BlockCodeEditor >> render: props [

	| editor blocks forceUpdate doCommand |
	editor := self useRef: SBEditor new.
	blocks := self useState: {}.
	forceUpdate := self useForceUpdate.
	
	self
		useEffect: [ | block |
			editor get openInWindow.
			
			"for testing purposes"
			block := SBTSStMethod for: Dictionary >> #associationsDo:.
			editor get openMorph: block.
			World doOneCycle.
			forceUpdate value.
			
			[editor get containingWindow ifNotNil: #delete]]
		dependencies: #().
	
	doCommand := self
		useCallback: [:command | Project current addDeferredUIMessage: [editor get do: command]]
		dependencies: {}.
	
	^ ApplicationDworph new
		translation: (props at: #translation ifAbsent: [Vector3 value: 0]);
		children: (GRProvider values: {#doSandblocksCommand -> doCommand} children: (Array streamContents: [:stream |
			editor get childSandblocksDo: [:sandblock |
				stream nextPut: (sandblock asCodeBlock
					layoutParams: (props at: #layoutParams);
					translation: Vector3 zero)]]))
	"GRRerenderEnforcer new"
]

{ #category : #'as yet unclassified' }
BlockCodeEditor >> useForceUpdate [

	| n |
	n := self useState: 0.
	^ [n set: [:old | old + 1]]
]

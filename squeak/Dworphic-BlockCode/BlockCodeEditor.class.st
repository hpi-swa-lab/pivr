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
			translation: -1 @ 1 @ 1;
			layoutParams: (CodeBlockLayoutParamters new
				blockDepth: 0.01;
				morphicScale: 0.003)]
]

{ #category : #'as yet unclassified' }
BlockCodeEditor >> render: props [

	| editor blocks forceUpdate doCommand globalTransform |
	editor := self useRef: SBEditor new.
	blocks := self useState: {}.
	forceUpdate := self useForceUpdate.
	
	self
		useEffect: [ | block |
			editor get openInWindow.
			
			"for testing purposes"
			block := SBTSStMethod for: Dictionary >> #associationsDo:.
			editor get openMorph: block.
			"World doOneCycle."
			forceUpdate value.
			
			[[editor get containingWindow ifNotNil: #delete]
				valueSupplyingAnswer: true]]
		dependencies: #().
	
	doCommand := self
		useCallback: [:command |
			Project current addDeferredUIMessage: [Transcript showln: 'doing ', command asString.editor get do: command].
			"editor get world doOneCycle."]
		dependencies: {}.
	
	globalTransform := self useRef: Matrix4x4 identity.
	
	^ ApplicationDworph new
		translation: (props at: #translation ifAbsent: [Vector3 value: 0]);
		children: (
			GRProvider values: {
				#doSandblocksCommand -> doCommand.
				#editorTransform -> [globalTransform get]}
			children: {
				GRDraggableAreaContainer new
					children: {
						GRRerenderEnforcer new.
						"dummy for retrieving global transform"
						GDSpatial new
							subscribeTo: 'global_transform' do: [:t | globalTransform set: t]},
						(Array streamContents: [:stream |
							editor get childSandblocksDo: [:sandblock |
								stream nextPut: (sandblock asCodeBlock
									layoutParams: (props at: #layoutParams);
									translation: Vector3 zero)]])})
]

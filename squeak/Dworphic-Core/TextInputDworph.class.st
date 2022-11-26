Class {
	#name : #TextInputDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
TextInputDworph >> pixelToMeter [
	"map 10px to 2cm"

	^ 2 cm
]

{ #category : #'as yet unclassified' }
TextInputDworph >> render: props [

	| text cursor textFocus callback hasFocus extent |
	textFocus := self useProvided: #textFocus.
	text := self useState: ''.
	extent := self useState: 0 @ 0.
	cursor := self useState: 0.
	callback := self useUpdatingRef: [:newText | text set: [:t | t, newText]].
	hasFocus := textFocus get textEnteredCallback = callback.
	
	self
		useEffect: [hasFocus ifTrue: [textFocus set: [:t | t copy cursorTransform: (t textAreaTopLeft localTranslatedBy: cursor get * 0.2 @ 0 @ 0)]]]
		dependencies: {cursor get. hasFocus}.
	
	^ GRInteractiveArea new
		point: true;
		grab: false;
		onButtonPress: [:e | e isTrigger ifTrue: [textFocus set: (GRTextFocus new textEnteredCallback: callback)]];
		children: {
			GDBoxShape new extents: extent get * self pixelToMeter @ 1 cm.
			GRViewportTexture new
				extent: extent get;
				children: (GDLineEdit new
					expandToTextLength: true;
					text: text get;
					caretPosition: cursor get;
					subscribeTo: #'rect_size' do: [:size |
						extent set: size.
						hasFocus ifTrue: [textFocus set: [:t | t copy textAreaExtent: size * self pixelToMeter]]];
					call: (hasFocus ifTrue: ['grab_focus'] ifFalse: ['release_focus']) arguments: #());
				meshDo: [:material |
					GDMeshInstance new
						mesh: (GDQuadMesh new
							size: extent get * self pixelToMeter;
							material: material);
						subscribeTo: #'global_transform'
							do: (hasFocus ifTrue: [[:transform | textFocus set: [:t | t copy textAreaCenter: transform]]])]}
]

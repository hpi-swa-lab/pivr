Class {
	#name : #TextInputDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
TextInputDworph >> pixelToMeter [
	"map 1px to 2mm"

	^ 2 mm
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
		props: props;
		point: true;
		grab: false;
		onButtonPress: [:e |
			(e isTrigger and: [hasFocus not]) ifTrue: [
				textFocus set: (GRTextFocus new
					textEnteredCallback: callback;
					textAreaExtent: extent get * self pixelToMeter)]];
		children: {
			GDCollisionShape new shape: (GDBoxShape new extents: extent get * self pixelToMeter @ 1 cm).
			GRViewportTexture new
				extent: extent get;
				children: (GDLineEdit new
					placeholderText: 'Text ...';
					expandToTextLength: true;
					text: text get;
					caretPosition: cursor get;
					subscribeTo: #'rect_size' do: [:size | | p |
						p := size first @ size second.
						extent set: p.
						hasFocus ifTrue: [textFocus set: [:t | t copy textAreaExtent: p * self pixelToMeter]]];
					call: (hasFocus ifTrue: ['grab_focus'] ifFalse: ['release_focus']) arguments: #());
				meshDo: [:material |
					GDMeshInstance new
						mesh: (GDQuadMesh new
							size: extent get * self pixelToMeter;
							material: material);
						subscribeTo: #'global_transform'
							do: (hasFocus ifTrue: [[:transform | textFocus set: [:t | t copy textAreaCenter: transform]]])]}
]

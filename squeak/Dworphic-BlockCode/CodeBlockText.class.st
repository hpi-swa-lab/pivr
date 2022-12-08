Class {
	#name : #CodeBlockText,
	#superclass : #GRComponent,
	#category : #'Dworphic-BlockCode'
}

{ #category : #'as yet unclassified' }
CodeBlockText >> render: props [

	props extract: [:layoutParams :morph | | font fontScale |
		font := self useMemo: [
			GDDynamicFont new
				fontData: (GDResourceLoader instance loadPath: 'res://assets/fonts/DejaVuSans.ttf')]
			dependencies: #().
		fontScale := 0.85. "this value depends to the used font"

		^ GDSpatial new
			children: {
				GDLabel3D new
					"horizontalAlignment: GDLabel3D alignLeft;"
					text: (morph contents);
					"Add a tiny little offset to the label translation to prevent z-fighting"
					translation: (Vector3 x: 0 y: 0 z: layoutParams blockDepth / 2) + 0.0001;
					pixelSize: layoutParams morphicScale * fontScale;
					font: font.
				morph hasCursor ifTrue: [
					(self methodAsComponent: #renderCursor:)
						morph: morph;
						layoutParams: layoutParams]}]
]

{ #category : #'as yet unclassified' }
CodeBlockText >> renderCursor: props [

	props extract: [:morph :layoutParams | | cursorPosition parentBounds callback textFocus extents hasFocus editor |
		cursorPosition := morph cursorPosition.
		parentBounds := morph bounds.
		textFocus := self useProvided: #textFocus.
		editor := self useProvided: #sandblocksEditor.
		callback := self useUpdatingRef: [:text |
			text do: [:char | editor handle: (SBTest keyboardEvent: char)]].
		extents := 2mm @ (parentBounds height * layoutParams morphicScale / 2).
		hasFocus := textFocus get textEnteredCallback = callback.
		
		self useEffect: [
			morph hasCursor
				ifTrue: [
					textFocus set: (GRTextFocus new
						textEnteredCallback: callback;
						textAreaExtent: layoutParams rootGlobalExtent;
						textAreaCenter: layoutParams rootGlobalTransform)].
				[hasFocus ifTrue: [
					textFocus set: GRTextFocus none]]]
			dependencies: {morph hasCursor}.
		
		self useEffect: [
			hasFocus ifTrue: [
				textFocus set: [:old | old copy textAreaCenter: layoutParams rootGlobalTransform]]]
			dependencies: {layoutParams rootGlobalTransform}.
		"self useEffect: [
			hasFocus ifTrue: [
				textFocus set: [:old | old copy textAreaExtent: layoutParams rootGlobalExtent]]]
			dependencies: {layoutParams rootGlobalExtent}."
		
		^ (self cubeVisualOfSize: 2m color: Color magenta)
			translation: ((cursorPosition x - parentBounds center x) * layoutParams morphicScale) @ 0 @ (layoutParams blockDepth / 2);
			scale: extents @ 2mm]
]

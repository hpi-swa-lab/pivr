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

	props extract: [:morph :layoutParams | | cursorPosition parentBounds |
		cursorPosition := morph cursorPosition.
		parentBounds := morph bounds.
		self useEffect: [Transcript showln: parentBounds height * layoutParams morphicScale] dependencies: {parentBounds height}.
		
		^ (self cubeVisualOfSize: 2m color: Color magenta)
			translation: ((cursorPosition x - parentBounds center x) * layoutParams morphicScale) @ 0 @ (layoutParams blockDepth / 2);
			scale: 2mm @ (parentBounds height * layoutParams morphicScale / 2) @ 2mm]
]

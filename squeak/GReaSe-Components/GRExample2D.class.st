Class {
	#name : #GRExample2D,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
GRExample2D >> render: props [

	| count pressed pressedSub toggledSub |
	count := self useState: 0.
	pressed := self useState: false.
	
	pressedSub := self useCallback: [count set: [:c | c + 1]] dependencies: {}.
	toggledSub := self useCallback: [:b | pressed set: b] dependencies: {}.
	
	^ GDVBoxContainer new children: {
		GDButton new
			text: 'Click me ', count get asString;
			onPressed: pressedSub.
		GDCheckButton new
			text: 'Checked';
			onToggled: toggledSub.
		GDButton new
			text: 'Reset';
			onPressed: [count set: 0].
		GDTextureRect new
			texture: (GDImageTexture new call: #load arguments: {'res://icon.png'});
			rectSize: 50 @ 50.
		GDCollisionShape2D new shape: (GDRectangleShape2D new extents: (Vector2 x: 100 * count get y: 30))}, ((1 to: count get) collect: [:i | GDLabel new text: 'Hello world'])
]

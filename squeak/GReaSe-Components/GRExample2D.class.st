Class {
	#name : #GRExample2D,
	#superclass : #CMFReactComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
GRExample2D >> render: props [

	| count rootRef |
	count := self useState: 0.
	rootRef := self useRef: nil.
	
	^ (self godot: #VBoxContainer)
		ref: rootRef;
		children: {
			(self godot: #Button)
				text: 'Click me ', count get asString;
				pressed: [count set: [:c | c + 1]].
			(self godot: #Button)
				text: 'Reset';
				pressed: [count set: 0].
			(self godot: #CollisionShape2D) shape: ((self godot: #RectangleShape2D) extents: (Vector2 x: 100 * count get y: 30))}, ((1 to: count get) collect: [:i | (self godot: #Label) text: 'Hello world!'])
]

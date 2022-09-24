Class {
	#name : #GRExample2D,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
GRExample2D >> render: props [

	| count rootRef pressed pressedSub toggledSub |
	count := self useState: 0.
	pressed := self useState: false.
	rootRef := self useRef: nil.
	
	pressedSub := self useCallback: [count set: [:c | c + 1]] dependencies: {}.
	toggledSub := self useCallback: [:b | pressed set: b] dependencies: {}.
	self
		useEffect: [
			Transcript showln: {'dep'. count get. pressed get}.
			nil]
		dependencies: {count get. pressed get}.
	
	^ (self godot: #VBoxContainer)
		ref: rootRef;
		children: {
			(self godot: #Button)
				text: 'Click me ', count get asString;
				pressed: pressedSub.
			(self godot: #CheckButton)
				text: 'Checked';
				toggled: toggledSub.
			(self godot: #Button)
				text: 'Reset';
				pressed: [count set: 0].
			(self godot: #CollisionShape2D) shape: ((self godot: #RectangleShape2D) extents: (Vector2 x: 100 * count get y: 30))}, ((1 to: count get) collect: [:i | (self godot: #Label) text: 'Hello world'])
]

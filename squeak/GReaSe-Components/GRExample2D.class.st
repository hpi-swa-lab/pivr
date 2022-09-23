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
	self
		useEffect: [
			rootRef get ifNotNil: [ | viewport |
				GRReactCurrentSession value
					callOn: 'ARVRServer'
					method: 'find_interface'
					arguments: {'OpenXR'}.
				viewport := GRReactCurrentSession value
					callOn: rootRef get
					method: 'get_viewport'
					arguments: {}.
				SBToggledCode comment: '' active: 0 do: {
					[
						GRReactCurrentSession value set: 'hdr' of: viewport to: false.
						GRReactCurrentSession value set: 'arvr' of: viewport to: true.
						GRReactCurrentSession value set: 'vsync_enabled' of: 'OS' to: true.
						GRReactCurrentSession value set: 'iterations_per_second' of: 'Engine' to: 90]}].
			nil]
		dependencies: {rootRef get}.
	
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

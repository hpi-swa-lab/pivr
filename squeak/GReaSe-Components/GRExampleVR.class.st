Class {
	#name : #GRExampleVR,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
GRExampleVR >> floor [

	^ (self godot: #StaticBody) children: {
		(self godot: #CollisionShape) shape: ((self godot: #BoxShape)
			extents: 5 @ 0.05 @ 5;
			margin: 0.0001).
		(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh) size: 10 @ 0.1 @ 10)}
]

{ #category : #'as yet unclassified' }
GRExampleVR >> render: props [

	| string enterKey cubes |
	string := self useState: ''.
	enterKey := self useCallback: [:key | string set: [:s | s, key asString]] dependencies: {}.
	cubes := self useState: (Array streamContents: [:s |
		30 timesRepeat: [
			s nextPut: {
				Color h: 360 atRandom s: 1 v: 1.
				Matrix4x4 withOffset: ThreadSafeRandom next - 0.5 @ 1.0 @ (ThreadSafeRandom next - 0.5).
				UUID new asString}]]).
	
	^ WorldDworph new children: {
		GRProvider values: {#keyEntered -> enterKey. #cubes -> cubes} children: {ToolBeltDworph new. self floor}, (cubes get withIndexCollect: [:p :index |
			CubeDworph new
				transform: p second;
				id: p third;
				color: p first;
				key: p third])}
]

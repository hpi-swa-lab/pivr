Class {
	#name : #GRExampleVR,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
GRExampleVR >> render: props [

	| string enterKey points |
	string := self useState: ''.
	enterKey := self useCallback: [:key | string set: [:s | s, key asString]] dependencies: {}.
	points := self
		useMemo: [Array streamContents: [:s | 30 timesRepeat: [s nextPut: {Color h: 360 atRandom s: 1 v: 1. ThreadSafeRandom next - 0.5 @ 1.0 @ (ThreadSafeRandom next - 0.5)}]]]
		dependencies: {}.
	
	^ WorldDworph new children: {
		GRProvider values: {#keyEntered -> enterKey} children: {
			AirwriteDworph new transform: (Matrix4x4 withOffset: 0 @ 0.2 @ -0.02).
			(self godot: #StaticBody) children: {
				(self godot: #CollisionShape) shape: ((self godot: #BoxShape)
					extents: 5 @ 0.05 @ 5;
					margin: 0.0001).
				(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh) size: 10 @ 0.1 @ 10)}}, (points withIndexCollect: [:p :index |
			CubeDworph new
				transform: (Matrix4x4 withOffset: p second);
				color: p first;
				key: index])}
]

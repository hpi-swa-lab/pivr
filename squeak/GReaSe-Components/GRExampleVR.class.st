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
		useMemo: [Array streamContents: [:s | 30 timesRepeat: [s nextPut: 100 atRandom - 50 @ 0 @ (100 atRandom - 50)]]]
		dependencies: {}.
	
	^ WorldDworph new children: {
		GRProvider values: {#keyEntered -> enterKey} children: {AirwriteDworph new transform: (Matrix4x4 withOffset: 1 @ 0.4 @ 1)}, (points collect: [:p |
			(self godot: #MeshInstance)
				translation: p;
				mesh: ((self godot: #CubeMesh) size: (Vector3 x: 1 y: 1 z: 1))])}
]

Class {
	#name : #SBTSVRTest,
	#superclass : #CMFReactComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
SBTSVRTest >> render: props [

	| string enterKey points |
	string := self useState: ''.
	enterKey := self useCallback: [:key | string set: [:s | s, key asString]] dependencies: {}.
	points := self
		useMemo: [Array streamContents: [:s | 10000 timesRepeat: [s nextPut: 100 atRandom - 50 @ 0 @ (100 atRandom - 50)]]]
		dependencies: {}.
	
	^ DworphicWorld asReactNodeBuilder
		props: {
			#leftControllerChildren -> {
				(self godot: #Label3D) text: string get.
				(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh) size: (Vector3 x: 0.01 y: 0.01 z: 0.01))}.
			#rightControllerChildren -> {
				(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh)
					size: (Vector3 x: 0.01 y: 0.01 z: 0.01);
					material: ((self godot: #SpatialMaterial) albedo_color: (Color r: 1 g: 0.0 b: 0.0)))}};
		children: {
			GRProvider values: {#keyEntered -> enterKey} children: {SBTSAirwrite asReactNodeBuilder build}, (points collect: [:p |
				(self godot: #MeshInstance)
					translation: p;
					mesh: ((self godot: #CubeMesh) size: (Vector3 x: 1 y: 1 z: 1))])};
		build
]

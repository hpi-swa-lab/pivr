Class {
	#name : #GRExampleVR,
	#superclass : #CMFReactComponent,
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
	
	^ WorldDworph new
		leftControllerChildren: {
			(self godot: #Label3D) text: string get.
			(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh) size: (Vector3 x: 0.01 y: 0.01 z: 0.01))};
		rightControllerChildren: {
			(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh)
				size: (Vector3 x: 0.01 y: 0.01 z: 0.01);
				material: ((self godot: #SpatialMaterial) albedo_color: (Color r: 1 g: 0.0 b: 0.0)))};
		children: {
			GRProvider values: {#keyEntered -> enterKey} children: {AirwriteDworph new}, (points collect: [:p |
				(self godot: #MeshInstance)
					translation: p;
					mesh: ((self godot: #CubeMesh) size: (Vector3 x: 1 y: 1 z: 1))])}
]

{ #category : #'as yet unclassified' }
GRExampleVR >> useVR [

	self
		useEffect: [ | openxr |
			openxr := GRReactCurrentSession value
				callOn: 'ARVRServer'
				method: 'find_interface'
				arguments: {'OpenXR'}.
			openxr ifNotNil: [ | sceneTree viewport |
				GRReactCurrentSession value
					callOn: openxr
					method: 'initialize'
					arguments: {}.
				sceneTree := GRReactCurrentSession value
					callOn: 'Engine'
					method: 'get_main_loop'
					arguments: {}.
				viewport := GRReactCurrentSession value get: 'root' of: sceneTree.
				GRReactCurrentSession value set: 'hdr' of: viewport to: false.
				GRReactCurrentSession value set: 'vsync_enabled' of: 'OS' to: true.
				GRReactCurrentSession value set: 'iterations_per_second' of: 'Engine' to: 90.
				GRReactCurrentSession value set: 'arvr' of: viewport to: true].
			nil]
		dependencies: {}
]

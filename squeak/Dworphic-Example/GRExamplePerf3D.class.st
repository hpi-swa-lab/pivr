Class {
	#name : #GRExamplePerf3D,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
GRExamplePerf3D >> render: props [

	| points cube |
	cube := self useMemo: [GDCubeMesh externalNew size: 1 @ 1 @ 1] dependencies: {}.
	
	points := self
		useMemo: [Array streamContents: [:s | 100 timesRepeat: [s nextPut: 20 atRandom @ 20 atRandom @ 20 atRandom]]]
		dependencies: {}.
	
	^ (points collect: [:point |
		(self methodAsComponent: #renderWiggle:)
			position: point;
			mesh: cube]), {GDCamera new transform: (Matrix4x4 lookAt: 0 @ 0 @ 0 from: 30 @ 30 @ 30 up: 0 @ 1 @ 0)}
]

{ #category : #'as yet unclassified' }
GRExamplePerf3D >> renderWiggle: props [

	| position |
	position := self useState: (props at: #position).
	
	^ {
		GDMeshInstance new
			translation: position get;
			mesh: (props at: #mesh).
		GDTimer new
			waitTime: 0.0001;
			onTimeout: [position set: [:x | x + (ThreadSafeRandom next * 20 - 10 @ (ThreadSafeRandom next * 20 - 10) @ (ThreadSafeRandom next * 20 - 10))]];
			autostart: true}
]

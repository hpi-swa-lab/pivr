Class {
	#name : #GRExamplePerf2D,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
GRExamplePerf2D >> render: props [

	| points |
	points := self
		useMemo: [Array streamContents: [:s | 500 timesRepeat: [s nextPut: 400 atRandom @ 400 atRandom]]]
		dependencies: {}.
	
	^ points collect: [:point | (self methodAsComponent: #renderWiggle:) position: point]
]

{ #category : #'as yet unclassified' }
GRExamplePerf2D >> renderWiggle: props [

	| position timeoutCallback |
	position := self useState: (props at: #position).
	timeoutCallback := self
		useCallback: [position set: [:x | x + (ThreadSafeRandom next * 20 - 10 @ (ThreadSafeRandom next * 20 - 10))]]
		dependencies: {}.
	
	^ (self godot: #ColorRect)
		rect_position: position get;
		rect_size: 30 @ 30;
		color: (Color r: 1 g: 0.0 b: 0.0);
		children: {
			(self godot: #Timer)
				wait_time: 0.0001;
				timeout: timeoutCallback;
				autostart: true}
]

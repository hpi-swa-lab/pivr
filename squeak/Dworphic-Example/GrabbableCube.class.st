Class {
	#name : #GrabbableCube,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
GrabbableCube class >> appDescription [
	<home>

	^ super appDescription
]

{ #category : #'as yet unclassified' }
GrabbableCube >> render: props [

	| color |
	color := self useState: (Color r: 1 g: 0.0 b: 0.0).
	
	^ GRGrabbableArea new
		onHover: [:event |
			Transcript showln: 'cube hover ', event side.
			color set: (Color r: 1 g: 1 b: 0.0)];
		onBlur: [:event |
			Transcript showln: 'cube blur ', event side.
			color set: (Color r: 1 g: 0.0 b: 0.0)];
		onGrab: [:event |
			Transcript showln: 'cube grab ', event side.
			color set: (Color r: 0.0 g: 1 b: 0.0)];
		onRelease: [:event |
			Transcript showln: 'cube release ', event side.
			color set: (Color r: 1 g: 1 b: 0.0)];
		onButtonPress: [:event | Transcript showln: 'cube button press ', event button];
		onButtonRelease: [:event | Transcript showln: 'cube button release ', event button];
		children: {self cubeOfSize: 0.2 color: color get}
]

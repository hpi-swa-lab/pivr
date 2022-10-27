Class {
	#name : #CubeApp,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
CubeApp class >> appDescription [
	<home>

	^ super appDescription
]

{ #category : #'as yet unclassified' }
CubeApp >> render: props [

	| cubes |
	cubes := self useState: [
		Array streamContents: [:s |
			30 timesRepeat: [
				s nextPut: {
					Color h: 360 atRandom s: 1 v: 1.
					Matrix4x4 withOffset: ThreadSafeRandom next - 0.5 @ 1.0 @ (ThreadSafeRandom next - 0.5).
					UUID new asString}]]].
	
	^ GRProvider values: {#cubes -> cubes} children: {
		GDStaticBody new children: (self cubeOfSize: 10 @ 0.1 @ 10 color: (Color r: 1 g: 1 b: 1)).
		CubeAddDworph new transform: (Matrix4x4 withOffset: 0.2 @ 1 @ 0).
		CubeRemoveDworph new transform: (Matrix4x4 withOffset: 0 @ 1 @ 0)}, (cubes get withIndexCollect: [:p :index |
		CubeDworph new
			transform: p second;
			id: p third;
			color: p first;
			key: p third])
]

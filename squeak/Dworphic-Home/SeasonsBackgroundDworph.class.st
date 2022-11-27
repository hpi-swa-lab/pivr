Class {
	#name : #SeasonsBackgroundDworph,
	#superclass : #GRComponent,
	#instVars : [
		'cube'
	],
	#category : #'Dworphic-Home'
}

{ #category : #'as yet unclassified' }
SeasonsBackgroundDworph class >> appDescription [
	<home>

	^ super appDescription
		toolPriority;
		rendersEnvironment: true
]

{ #category : #'as yet unclassified' }
SeasonsBackgroundDworph >> autumn [

	| r |
	r := Random new seed: 173.
	^ Array streamContents: [:stream |
		stream nextPut: ((self
			cubeVisualOfSize: self centerSize @ 1 cm @ self centerSize
			color: (Color r: 0.643 g: 0.603 b: 0.162)) translation: self centerSize negated @ 0 @ 0).
		10 timesRepeat: [
			stream nextPut: (self
				tree: r next + 0.7 * 0.6
				at: r next @ r next * self centerSize + (self centerSize * -1.5 @ (self centerSize / -2))
				rotated: r next * Float pi
				leafColor: (Color r: 0.955 g: 0.66 b: 0.115))]]
]

{ #category : #'as yet unclassified' }
SeasonsBackgroundDworph >> centerSize [

	^ 3 m
]

{ #category : #'as yet unclassified' }
SeasonsBackgroundDworph >> floor [

	^ self cubeOfSize: self centerSize @ 1 cm @ self centerSize color: (Color gray: 0.8)
]

{ #category : #'as yet unclassified' }
SeasonsBackgroundDworph >> light [

	^ GDDirectionalLight new
		shadowEnabled: true;
		transform: (Matrix4x4 lookAt: 0 @ 0 @ 0 from: 10 @ 10 @ 10 up: 0 @ 1 @ 0)
]

{ #category : #'as yet unclassified' }
SeasonsBackgroundDworph >> render: props [

	cube := self useMemo: [GDCubeMesh externalNew size: 1 @ 1 @ 1] dependencies: {}.
	^ {self floor. self light. self summer. self winter. self spring. self autumn}
]

{ #category : #'as yet unclassified' }
SeasonsBackgroundDworph >> spring [

	| r |
	r := Random new seed: 142.
	^ Array streamContents: [:stream |
		stream nextPut: ((self
			cubeVisualOfSize: self centerSize @ 1 cm @ self centerSize
			color: (Color r: 0.559 g: 0.93 b: 0.274)) translation: self centerSize @ 0 @ 0).
		10 timesRepeat: [
			stream nextPut: (self
				tree: r next + 0.7 * 0.7
				at: r next @ r next * self centerSize + (self centerSize / 2 @ (self centerSize / -2))
				rotated: r next * Float pi
				leafColor: (Color r: 0.108 g: 0.656 b: 0.108))]]
]

{ #category : #'as yet unclassified' }
SeasonsBackgroundDworph >> summer [

	| step r material |
	step := 30 cm.
	r := Random new seed: 42.
	material := self
		useMemo: [GDSpatialMaterial externalNew albedoColor: Color yellow]
		dependencies: {}.
	^ Array streamContents: [:stream |
		self centerSize negated / 2 to: self centerSize / 2 by: step do: [:x |
			self centerSize negated / 2 to: self centerSize / 2 by: step do: [:y |
				stream nextPut: (GDMeshInstance new
					translation: x @ (r next * 10 cm) @ y + (step / 2 @ (step negated + 10 cm) @ self centerSize);
					scale: step @ step @ step;
					call: 'set_surface_material' arguments: {0. material};
					mesh: cube)]]]
]

{ #category : #'as yet unclassified' }
SeasonsBackgroundDworph >> tree: aNumber at: aVector rotated: anotherNumber leafColor: aColor [

	^ GDSpatial new
		scale: aNumber @ aNumber @ aNumber;
		rotationDegrees: 0 @ anotherNumber @ 0;
		translation: aVector x @ 0 @ aVector y;
		children: {
			(self cubeVisualOfSize: 0.2 asVector3 color: (Color r: 0.6 g: 0.2 b: 0.0)) translation: 0 @ 0.1 @ 0.
			(self cubeVisualOfSize: 0.6 @ 1.8 @ 0.6 color: aColor) translation: 0 @ (0.9 + 0.2) @ 0}
]

{ #category : #'as yet unclassified' }
SeasonsBackgroundDworph >> winter [

	| step r variation material |
	step := 30 cm.
	variation := 60 cm.
	r := Random new seed: 44.
	material := self
		useMemo: [GDSpatialMaterial externalNew albedoColor: (Color r: 1 g: 1 b: 1)]
		dependencies: {}.
	^ Array streamContents: [:stream |
		self centerSize negated / 2 to: self centerSize / 2 by: step do: [:x |
			self centerSize negated / 2 to: self centerSize / 2 by: step do: [:y |
				stream nextPut: (GDMeshInstance new
					mesh: cube;
					scale: step @ variation @ step;
					translation: x @ (r next * variation) @ y + (step / 2 @ (variation / 2) negated @ (self centerSize negated + step));
					call: 'set_surface_material' arguments: {0. material})]]]
]

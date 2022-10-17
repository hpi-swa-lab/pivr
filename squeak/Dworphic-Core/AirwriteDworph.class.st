Class {
	#name : #AirwriteDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #detection }
AirwriteDworph >> checkMatch: aCollection [

	{
		'a' -> 'urd'.
		'b' -> 'durdl'.
		'c' -> 'ldr'.
		'd' -> 'ldru'.
		'e' -> 'lrlr'.
		'f' -> 'ur'.
		'g' -> 'ldrul'.
		'h' -> 'durd'.
		'i' -> 'd'.
		'j' -> 'rdl'.
		'k' -> 'drld'.
		'l' -> 'dr'.
		'm' -> 'udr?ud'.
		'n' -> 'udu'.
		'o' -> 'drul'.
		'p' -> 'urdl'.
		'q' -> 'ldrl'.
		'r' -> 'dur'.
		's' -> 'ldrd'.
		't' -> 'rd'.
		'u' -> 'dru'.
		'v' -> 'du'.
		'w' -> 'dudu'.
		'x' -> 'dlu'.
		'y' -> 'dudlu?'.
		'z' -> 'rdr'.
		'1' -> 'u'.
		'2' -> 'lul'.
		'3' -> 'rlrl'.
		'4' -> 'udl'.
		'5' -> 'rul'.
		'6' -> 'lu'.
		'7' -> 'ul'.
		'8' -> 'ulrl'.
		'9' -> 'uld'.
		'0' -> 'uldr'.
		'{' -> 'ulru'.
		'[' -> 'lur'.
		'(' -> 'ld'.
		'#' -> 'ududl'.
		' ' -> 'r'.
		'-' -> 'ldl'.
		'+' -> 'rud'.
		'*' -> 'rlud'.
		'/' -> 'uru'.
		'$' -> 'urlu'.
		'%' -> 'urul'.
		'=' -> 'lrl'.
		'"' -> 'dud'.
		'~' -> 'rur'.
		'.' -> 'lrd'.
		'&' -> 'lurul'.
		'!' -> 'drl'.
		'_' -> 'dldl'.
		'^' -> 'ud'.
		'?' -> 'rdld'.
		'`' -> 'lrd'.
		'''' -> 'udr'.
		':' -> 'ldlr'.
		'<' -> 'lr'.
		'>' -> 'rl'.
		'|' -> 'x'.
		'\b' -> 'l'.
		'\n' -> 'dl'.
		'\t' -> 'x'.
		'.' -> 'lrdu'} do: [:pair | ((aCollection joinSeparatedBy: '') matchesRegex: pair value) ifTrue: [^ pair key]].
	^ nil
]

{ #category : #'as yet unclassified' }
AirwriteDworph >> collisionShape [

	^ (self godot: #CylinderShape)
		height: self length;
		radius: self radius * 2;
		margin: 0.0001
]

{ #category : #detection }
AirwriteDworph >> detectChar: aCollection head: headPosition [

	| directions |
	directions := Array streamContents: [:s |
		(self thinPoints: aCollection) overlappingPairsDo: [:a :b | | direction |
			direction := self directionOfStrokeFrom: a to: b headPosition: headPosition.
			(s size < 1 or: [direction ~= s last]) ifTrue: [s nextPut: direction]]].
	
	^ self checkMatch: directions
]

{ #category : #detection }
AirwriteDworph >> directionOfStrokeFrom: a to: b headPosition: head [

	| delta |
	delta := (a - b) abs.
	^ (delta x * delta x + (delta z * delta z)) sqrt > delta y
		ifTrue: [ | p1 p2 |
			p1 := a - head.
			p2 := b - head.
			(p1 x @ p1 z angleWith: p2 x @ p2 z) > (Float pi / 2)
				ifTrue: ['l']
				ifFalse: ['r']]
		ifFalse: [b y > a y ifTrue: ['u'] ifFalse: ['d']]
]

{ #category : #'as yet unclassified' }
AirwriteDworph >> length [

	^ 0.1
]

{ #category : #'as yet unclassified' }
AirwriteDworph >> radius [

	^ 0.005
]

{ #category : #rendering }
AirwriteDworph >> render: props [

	^ ControllerToolDworph new
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		shape: self collisionShape;
		shapeTransform: (Matrix4x4 withOffset: 0 @ (self length / 2) @ 0);
		onRelease: #return;
		active: [(self methodAsComponent: #renderActive:) props: props];
		passive: [(self methodAsComponent: #renderPassive:) props: props]
]

{ #category : #rendering }
AirwriteDworph >> renderActive: props [

	| controllerTranslation lastControllerTranslation curveRef buttonPressed headPosition points worldPortal controllerTransform |
	worldPortal := self useWorldPortal.
	points := self useState: {}.
	lastControllerTranslation := self useState: Vector3 zero.
	
	headPosition := self useHeadTransform translation.
	controllerTransform := self useControllerTransform.
	controllerTranslation := controllerTransform translation.
	buttonPressed := self useTriggerStrength > 0.6.
	
	curveRef := self useGodotRef.
	
	self
		useEffect: [
			(lastControllerTranslation get distanceTo: controllerTranslation) > 0.01 ifTrue: [
				lastControllerTranslation set: controllerTranslation.
				buttonPressed ifTrue: [ | position |
					position := self tipPosition: controllerTransform.
					points set: [:p | p copyWith: position].
					curveRef get addPointPosition: position]].
			(points get notEmpty and: [buttonPressed not]) ifTrue: [
				Transcript showln: (self detectChar: points get head: headPosition).
				curveRef get clearPoints.
				points set: {}]]
		dependencies: {controllerTranslation. buttonPressed}.
	
	^ GDSpatial new children: {
		self renderPassive: props.
		CMFReactNodePortal
			child: {
				GDPath new
					curve: (GDCurve3D new
						ref: curveRef;
						bakeInterval: 0.01);
					name: 'path'.
				GDCSGPolygon new
					pathNode: (GRNodePath path: '../path');
					polygon: (GRPoolVector2Array new
						add: (Vector2 x: -0.005 y: -0.005);
						add: (Vector2 x: -0.005 y: 0.005);
						add: (Vector2 x: 0.005 y: 0.005);
						add: (Vector2 x: 0.005 y: -0.005);
						yourself);
					mode: GDCSGPolygon modePath;
					pathIntervalType: GDCSGPolygon pathIntervalDistance;
					pathInterval: 0.01;
					pathSimplifyAngle: 0.0;
					pathRotation: GDCSGPolygon pathRotationPathFollow;
					pathLocal: true;
					pathJoined: false;
					pathContinuousU: true;
					pathUDistance: 0.71;
					smoothFaces: true}
			in: worldPortal}
]

{ #category : #rendering }
AirwriteDworph >> renderPassive: props [

	^ (self godot: #MeshInstance)
		mesh: ((self godot: #CylinderMesh)
			height: self length;
			top_radius: self radius;
			bottom_radius: self radius;
			radial_segments: 12);
		translation: 0 @ (self length / 2) @ 0
]

{ #category : #detection }
AirwriteDworph >> thinPoints: aCollection [

	^ Array streamContents: [:stream |
		stream nextPut: aCollection first.
		aCollection allButFirstDo: [:point | (point distanceTo: stream last) > 0.03 ifTrue: [stream nextPut: point]]]
]

{ #category : #'as yet unclassified' }
AirwriteDworph >> tipPosition: controllerTransform [

	^ controllerTransform transform: 0 @ self length @ 0
]

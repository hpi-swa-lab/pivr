Class {
	#name : #AirwriteDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Tools'
}

{ #category : #'as yet unclassified' }
AirwriteDworph class >> appDescription [
	<home>

	^ super appDescription
]

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

	| grabbed pressed |
	grabbed := self useState: false.
	pressed := self useState: false.
	
	^ GRGrabbableArea new
		children: {
			GDCollisionShape new shape: self collisionShape.
			self stick.
			grabbed get
				ifTrue: [(self methodAsComponent: #renderActive:) pressed: pressed get]
				ifFalse: [nil]};
		onButtonPress: [:e | e isTrigger ifTrue: [pressed set: true]];
		onButtonRelease: [:e | e isTrigger ifTrue: [pressed set: false]];
		onGrab: [grabbed set: true];
		onRelease: [grabbed set: false]
]

{ #category : #rendering }
AirwriteDworph >> renderActive: props [

	| curveRef buttonPressed headPosition points worldPortal lastTipTranslation tipTransform |
	worldPortal := self useWorldPortal.
	headPosition := self useHeadTransform translation.
	buttonPressed := props at: #pressed.
	
	points := self useState: {}.
	lastTipTranslation := self useState: Vector3 zero.
	tipTransform := self useState: Matrix4x4 identity.
	
	curveRef := self useGodotRef.
	
	self
		useEffect: [
			(lastTipTranslation get distanceTo: tipTransform get translation) > 0.01 ifTrue: [
				lastTipTranslation set: tipTransform get translation.
				buttonPressed ifTrue: [
					points set: [:p | p copyWith: tipTransform get translation].
					curveRef get addPointPosition: tipTransform get translation]].
			(points get notEmpty and: [buttonPressed not]) ifTrue: [
				Transcript showln: (self detectChar: points get head: headPosition).
				curveRef get clearPoints.
				points set: {}]]
		dependencies: {tipTransform get translation. buttonPressed}.
	
	^ GDSpatial new children: {
		GDPosition3D new
			translation: 0 @ self length @ 0;
			subscribeTo: #'global_transform' do: tipTransform setter.
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
AirwriteDworph >> stick [

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

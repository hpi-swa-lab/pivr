Class {
	#name : #AirwriteDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
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
		height: 0.1;
		radius: 0.02;
		margin: 0.001
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
			(SBWatch report: (p1 x @ p1 z angleWith: p2 x @ p2 z) for: 512906530) > (Float pi / 2)
				ifTrue: ['l']
				ifFalse: ['r']]
		ifFalse: [b y > a y ifTrue: ['u'] ifFalse: ['d']]
]

{ #category : #rendering }
AirwriteDworph >> render: props [

	^ ControllerToolDworph new
		transform: (props at: #transform);
		shape: self collisionShape;
		active: [(self methodAsComponent: #renderActive:) props: props];
		passive: [(self methodAsComponent: #renderPassive:) props: props]
]

{ #category : #rendering }
AirwriteDworph >> renderActive: props [

	| controllerTranslation lastControllerTranslation curveRef buttonPressed headPosition points worldPortal |
	worldPortal := self useWorldPortal.
	points := self useState: {}.
	lastControllerTranslation := self useState: Vector3 zero.
	
	headPosition := self useHeadTransform translation.
	controllerTranslation := self useControllerTransform translation.
	buttonPressed := self useGripPressed.
	
	curveRef := self useRef: nil.
	
	self
		useEffect: [
			curveRef get ifNotNil: [
				(lastControllerTranslation get distanceTo: controllerTranslation) > 0.01 ifTrue: [
					lastControllerTranslation set: controllerTranslation.
					buttonPressed ifTrue: [
						points set: [:p | p copyWith: controllerTranslation].
						GRReactCurrentSession value
							callOn: curveRef get
							method: 'add_point'
							arguments: {controllerTranslation}]]].
			nil]
		dependencies: {controllerTranslation. buttonPressed}.
	
	self
		useEffect: [
			"return a clean-up effect for when this component is unmounted -- in other words, when the tool is let go by the user"
			[
				points get notEmpty ifTrue: [
					Transcript showln: (self detectChar: points get head: headPosition).
					GRReactCurrentSession value
						callOn: curveRef get
						method: 'clear_points'
						arguments: {}.
					points set: {}]]]
		dependencies: {}.
	
	^ (self godot: #Spatial) children: {
		self renderPassive: props.
		CMFReactNodePortal
			child: {
				(self godot: #Path)
					curve: ((self godot: #Curve3D)
						ref: curveRef;
						bake_interval: 0.01);
					key: 'path'.
				(self godot: #CSGPolygon)
					path_node: (GRNodePath path: '../path');
					polygon: (GRPoolVector2Array new
						add: (Vector2 x: -0.005 y: -0.005);
						add: (Vector2 x: -0.005 y: 0.005);
						add: (Vector2 x: 0.005 y: 0.005);
						add: (Vector2 x: 0.005 y: -0.005);
						yourself);
					mode: 2;
					path_interval_type: 0;
					path_interval: 0.01;
					path_simplify_angle: 0.0;
					path_rotation: 2;
					path_local: true;
					path_joined: false;
					path_continuous_u: true;
					path_u_distance: 0.71;
					smooth_faces: true}
			in: worldPortal}
]

{ #category : #rendering }
AirwriteDworph >> renderPassive: props [

	^ (self godot: #MeshInstance) mesh: self shape
]

{ #category : #'as yet unclassified' }
AirwriteDworph >> shape [

	^ (self godot: #CylinderMesh)
		height: 0.1;
		top_radius: 0.02;
		bottom_radius: 0.02;
		radial_segments: 12
]

{ #category : #detection }
AirwriteDworph >> thinPoints: aCollection [

	^ Array streamContents: [:stream |
		stream nextPut: aCollection first.
		aCollection allButFirstDo: [:point | (point distanceTo: stream last) > 0.03 ifTrue: [stream nextPut: point]]]
]

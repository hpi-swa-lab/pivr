Class {
	#name : #ControllerToolDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #rendering }
ControllerToolDworph >> colliderShape: props [

	^ (self godot: #CollisionShape)
		shape: (props at: #shape);
		transform: (props at: #shapeTransform ifAbsent: [Matrix4x4 identity])
]

{ #category : #rendering }
ControllerToolDworph >> render: props [

	| controllerIntersecting rightHandId leftHandId grabbed onRelease transform rigidBody |
	onRelease := props at: #onRelease ifAbsent: [nil].
	
	grabbed := self useState: 0.
	controllerIntersecting := self useState: 0.
	
	leftHandId := self useProvided: #handId namespace: #left.
	rightHandId := self useProvided: #handId namespace: #right.
	
	transform := self useRef: (props at: #transform ifAbsent: [Matrix4x4 identity]).
	
	rigidBody := self useGodotRef.
	self
		useEffect: [(grabbed get = 0 and: [onRelease = #drop]) ifTrue: [rigidBody get transform: transform get]]
		dependencies: {grabbed get. onRelease}.
	
	^ {
		(self methodAsComponent: #renderForHand:) props: props, {
			#side -> ((controllerIntersecting get = 1 or: [grabbed get = 1])
				ifTrue: [#left]
				ifFalse: [#right]).
			#intersecting -> (controllerIntersecting get ~= 0).
			#grabbed -> grabbed get.
			#onGrabbed -> [:val | grabbed set: val].
			#onTransform -> [:val | transform set: val]}.
		grabbed get = 0 ifTrue: [ | pickableNode |
			pickableNode := GDArea new
				meta: #id set: (props at: #id ifAbsent: nil);
				onAreaEntered: [:other |
					other = leftHandId get ifTrue: [controllerIntersecting set: 1].
					other = rightHandId get ifTrue: [controllerIntersecting set: 2]];
				onAreaExited: [:other |
					(controllerIntersecting get = 1 and: [other = leftHandId get]) ifTrue: [controllerIntersecting set: 0].
					(controllerIntersecting get = 2 and: [other = rightHandId get]) ifTrue: [controllerIntersecting set: 0]];
				children: {(props at: #passive) value. self colliderShape: props}.
			onRelease = #drop
				ifTrue: [
					GDRigidBody new
						ref: rigidBody;
						continuousCd: true;
						children: {pickableNode. self colliderShape: props}]
				ifFalse: [pickableNode transform: transform get]]}
]

{ #category : #rendering }
ControllerToolDworph >> renderForHand: props [

	| gripPressed grabbed portal controllerTransformLeft onRelease handIsFree side controllerTransformRight |
	grabbed := props at: #grabbed.
	side := props at: #side.
	
	gripPressed := (self useProvided: #pressedButtons namespace: side) includes: GDGlobalConstants joyVrGrip.
	controllerTransformLeft := self useProvidedRef: #controllerTransform namespace: #left.
	controllerTransformRight := self useProvidedRef: #controllerTransform namespace: #right.
	onRelease := props at: #onRelease ifAbsent: [nil].
	handIsFree := self useProvided: #handIsFree namespace: side.
	portal := self useProvided: #handPortal namespace: side.
	
	self
		useEffect: [
			((props at: #intersecting) and: [gripPressed and: [handIsFree get]]) ifTrue: [
				(props at: #onGrabbed) value: (side = #left ifTrue: [1] ifFalse: [2]).
				handIsFree set: false].
			(grabbed ~= 0 and: [gripPressed not]) ifTrue: [
				({#stay. #drop} includes: onRelease) ifTrue: [(props at: #onTransform) value: (side = #left ifTrue: [controllerTransformLeft get] ifFalse: [controllerTransformRight get])].
				(props at: #onGrabbed) value: 0.
				handIsFree set: true]]
		dependencies: {props at: #onGrabbed. props at: #intersecting. props at: #onTransform. gripPressed}.
	
	^ grabbed ~= 0 ifTrue: [
		GRUseProviderNamespace
			namespace: side
			children: {CMFReactNodePortal child: (props at: #active) value in: portal}]
]

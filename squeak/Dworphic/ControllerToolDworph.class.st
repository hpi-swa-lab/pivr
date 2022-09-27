Class {
	#name : #ControllerToolDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #rendering }
ControllerToolDworph >> colliderShape: props [

	^ (self godot: #CollisionShape)
		shape: (props at: #shape);
		transform: (props at: #shapeTransform ifAbsent: [Matrix4x4 identity])
]

{ #category : #rendering }
ControllerToolDworph >> render: props [

	| controllerIntersecting enteredSub exitedSub rightHandId leftHandId grabbed onRelease rigidBodyPosInitialized transform grabbedSub transformSub |
	onRelease := props at: #onRelease ifAbsent: [nil].
	
	grabbed := self useState: 0.
	controllerIntersecting := self useState: 0.
	
	leftHandId := self useProvided: #handId namespace: #left.
	rightHandId := self useProvided: #handId namespace: #right.
	
	transform := self useState: (props at: #transform ifAbsent: [Matrix4x4 identity]).
	rigidBodyPosInitialized := self useRef: false.
	
	enteredSub := self
		useCallback: [:other |
			other = leftHandId get ifTrue: [controllerIntersecting set: 1].
			other = rightHandId get ifTrue: [controllerIntersecting set: 2]]
		dependencies: {}.
	exitedSub := self
		useCallback: [:other |
			(controllerIntersecting get = 1 and: [other = leftHandId get]) ifTrue: [controllerIntersecting set: 0].
			(controllerIntersecting get = 2 and: [other = rightHandId get]) ifTrue: [controllerIntersecting set: 0]]
		dependencies: {}.
	grabbedSub := self useCallback: [:val | grabbed set: val] dependencies: {}.
	transformSub := self
		useCallback: [:val |
			transform set: val.
			rigidBodyPosInitialized set: false]
		dependencies: {}.
	
	^ {
		(self methodAsComponent: #renderForHand:) props: props, {
			#side -> ((controllerIntersecting get = 1 or: [grabbed get = 1])
				ifTrue: [#left]
				ifFalse: [#right]).
			#intersecting -> (controllerIntersecting get ~= 0).
			#grabbed -> grabbed get.
			#onGrabbed -> grabbedSub.
			#onTransform -> transformSub}.
		grabbed get = 0 ifTrue: [ | pickableNode |
			pickableNode := (self godot: #Area)
				meta: #id set: (props at: #id ifAbsent: nil);
				area_entered: enteredSub;
				area_exited: exitedSub;
				children: {(props at: #passive) value. self colliderShape: props}.
			onRelease = #drop
				ifTrue: [ | node |
					node := (self godot: #RigidBody)
						continuous_cd: true;
						children: {pickableNode. self colliderShape: props}.
					rigidBodyPosInitialized get ifFalse: [
						node transform: transform get.
						rigidBodyPosInitialized set: true].
					node]
				ifFalse: [pickableNode transform: transform get]]}
]

{ #category : #rendering }
ControllerToolDworph >> renderForHand: props [

	| gripPressed grabbed portal controllerTransformLeft onRelease handIsFree side controllerTransformRight |
	grabbed := props at: #grabbed.
	side := props at: #side.
	
	gripPressed := (self useProvided: #pressedButtons namespace: side) includes: 6.
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
				handIsFree set: true].
			nil]
		dependencies: {props at: #onGrabbed. props at: #onTransform. gripPressed}.
	
	^ grabbed ~= 0 ifTrue: [
		GRUseProviderNamespace
			namespace: side
			children: {CMFReactNodePortal child: (props at: #active) value in: portal}]
]

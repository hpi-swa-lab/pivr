Class {
	#name : #ControllerToolDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #'as yet unclassified' }
ControllerToolDworph >> colliderShape: props [

	^ (self godot: #CollisionShape)
		shape: (props at: #shape);
		transform: (props at: #shapeTransform ifAbsent: [Matrix4x4 identity])
]

{ #category : #rendering }
ControllerToolDworph >> render: props [

	| controllerIntersecting gripPressed grabbed portal enteredSub exitedSub transform controllerTransform onRelease rigidBodyPosInitialized handId handIsFree |
	"on release: return, drop, stay, keep"
	grabbed := self useState: false.
	controllerIntersecting := self useState: false.
	gripPressed := self useGripPressed.
	portal := self useHandPortal.
	controllerTransform := self useProvidedRef: #controllerTransform.
	transform := self useState: (props at: #transform ifAbsent: [Matrix4x4 identity]).
	onRelease := props at: #onRelease ifAbsent: [nil].
	rigidBodyPosInitialized := self useRef: false.
	handId := self useHandId.
	handIsFree := self useHandIsFree.
	
	self
		useEffect: [
			(controllerIntersecting get and: [gripPressed and: [handIsFree get]]) ifTrue: [
				controllerIntersecting set: false.
				grabbed set: true.
				handIsFree set: false].
			(grabbed get and: [gripPressed not]) ifTrue: [
				grabbed set: false.
				handIsFree set: true.
				({#stay. #drop} includes: onRelease) ifTrue: [transform set: controllerTransform get].
				rigidBodyPosInitialized set: false].
			nil]
		dependencies: {controllerIntersecting get. gripPressed}.
	
	enteredSub := self
		useCallback: [:other | other = handId get ifTrue: [controllerIntersecting set: true]]
		dependencies: {}.
	exitedSub := self
		useCallback: [:other | other = handId get ifTrue: [controllerIntersecting set: false]]
		dependencies: {}.
	
	^ grabbed get
		ifTrue: [CMFReactNodePortal child: (props at: #active) value in: portal]
		ifFalse: [ | pickableNode |
			pickableNode := (self godot: #Area)
				meta_id: (props at: #id ifAbsent: nil);
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
				ifFalse: [pickableNode transform: transform get]]
]

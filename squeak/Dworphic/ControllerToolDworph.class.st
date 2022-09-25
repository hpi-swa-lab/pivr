Class {
	#name : #ControllerToolDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #rendering }
ControllerToolDworph >> render: props [

	| controllerIntersecting gripPressed grabbed portal enteredSub exitedSub transform controllerTransform onRelease rigidBodyPosInitialized handId |
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
	
	self
		useEffect: [
			(controllerIntersecting get and: [gripPressed]) ifTrue: [
				controllerIntersecting set: false.
				grabbed set: true].
			(grabbed get and: [gripPressed not]) ifTrue: [
				grabbed set: false.
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
				area_entered: enteredSub;
				area_exited: exitedSub;
				children: {
					(props at: #passive) value.
					(self godot: #CollisionShape)
						shape: (props at: #shape);
						transform: (props at: #shapeTransform ifAbsent: [Matrix4x4 identity])}.
			onRelease = #drop
				ifTrue: [ | node |
					node := (self godot: #RigidBody)
						continuous_cd: true;
						children: {
							pickableNode.
							(self godot: #CollisionShape)
								shape: (props at: #shape);
								transform: (props at: #shapeTransform ifAbsent: [Matrix4x4 identity])}.
					rigidBodyPosInitialized get ifFalse: [
						node transform: transform get.
						rigidBodyPosInitialized set: true].
					node]
				ifFalse: [pickableNode transform: transform get]]
]

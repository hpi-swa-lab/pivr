Class {
	#name : #ControllerToolDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #rendering }
ControllerToolDworph >> render: props [

	| controllerIntersecting gripPressed grabbed portal enteredSub exitedSub transform controllerTransform |
	"on release: return, drop, stay, keep"
	grabbed := self useState: false.
	controllerIntersecting := self useState: false.
	gripPressed := self useGripPressed.
	portal := self useHandPortal.
	controllerTransform := self useProvidedRef: #controllerTransform.
	transform := self useState: (props at: #transform ifAbsent: [Matrix4x4 identity]).
	
	self
		useEffect: [
			(controllerIntersecting get and: [gripPressed]) ifTrue: [grabbed set: true].
			(grabbed get and: [gripPressed not]) ifTrue: [
				grabbed set: false.
				(props at: #onRelease ifAbsent: [nil]) == #stay ifTrue: [transform set: controllerTransform get]].
			nil]
		dependencies: {controllerIntersecting get. gripPressed}.
	
	enteredSub := self useCallback: [:other | controllerIntersecting set: true] dependencies: {}.
	exitedSub := self useCallback: [:other | controllerIntersecting set: false] dependencies: {}.
	
	^ grabbed get
		ifTrue: [CMFReactNodePortal child: (props at: #active) value in: portal]
		ifFalse: [
			(self godot: #Area)
				transform: transform get;
				area_entered: enteredSub;
				area_exited: exitedSub;
				children: {
					(props at: #passive) value.
					(self godot: #CollisionShape)
						shape: (props at: #shape);
						transform: (props at: #shapeTransform ifAbsent: [Matrix4x4 identity])}]
]

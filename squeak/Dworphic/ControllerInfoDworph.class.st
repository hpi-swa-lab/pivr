Class {
	#name : #ControllerInfoDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #'as yet unclassified' }
ControllerInfoDworph class >> grip [

	^ 2
]

{ #category : #'as yet unclassified' }
ControllerInfoDworph class >> triggerAxis [

	^ 2
]

{ #category : #rendering }
ControllerInfoDworph >> render: props [

	| handPortal transform transformSub buttonPressed buttonRelase pressedButtons controllerNode axes handArea handIsFree |
	handPortal := self useRef: nil.
	handArea := self useRef: nil.
	
	handIsFree := self useState: true.
	transform := self useState: Matrix4x4 identity.
	transformSub := self useCallback: [:t | transform set: t] dependencies: {}.
	
	axes := {{self class triggerAxis. #trigger}. {7. #grip}. {0. #'touchpad_x'}. {1. #'touchpad_y'}} collect: [:axis | | state subscriber |
		state := self useState: 0.0.
		subscriber := self useCallback: [:s | state set: s] dependencies: {}.
		axis, {state. subscriber}].
	
	pressedButtons := self useState: {}.
	buttonPressed := self
		useCallback: [:button | pressedButtons set: [:b | b copyWith: button]]
		dependencies: {}.
	buttonRelase := self
		useCallback: [:button | pressedButtons set: [:b | b copyWithout: button]]
		dependencies: {}.
	
	controllerNode := (self godot: #ARVRController)
		controller_id: ((props at: #left) == true ifTrue: [1] ifFalse: [2]);
		children: {
			(self godot: #Area)
				children: {
					(self godot: #CollisionShape) shape: ((self godot: #SphereShape)
						margin: 0.001;
						radius: 0.005)};
				ref: handArea.
			(self godot: #Spatial) ref: [:node | handPortal set: node].
			(self godot: #MeshInstance) mesh: ((self godot: #SphereMesh)
				radius: 0.005;
				height: 0.01)};
		button_pressed: buttonPressed;
		button_release: buttonRelase;
		subscribeTo: #'global_transform' do: transformSub.
	
	axes do: [:axis | controllerNode subscribeCall: 'get_joystick_axis' with: {axis first} do: axis fourth].
	
	^ {
		GRProvider
			namespace: ((props at: #left) == true ifTrue: [#left] ifFalse: [#right])
			values: {
				#controllerTransform -> transform get.
				#handPortal -> handPortal.
				#handId -> handArea.
				#handIsFree -> handIsFree.
				#pressedButtons -> pressedButtons get}, (axes collect: [:axis | axis second -> axis third get])
			children: ((props at: #do) value: controllerNode)}
]

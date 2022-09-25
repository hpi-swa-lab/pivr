Class {
	#name : #ControllerInfoDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #rendering }
ControllerInfoDworph >> render: props [

	| handPortal transform transformSub buttonPressed buttonRelase pressedButtons controllerNode axes handArea |
	handPortal := self useRef: nil.
	handArea := self useRef: nil.
	
	transform := self useState: Matrix4x4 identity.
	transformSub := self useCallback: [:t | transform set: t] dependencies: {}.
	
	axes := {{2. #trigger}. {7. #grip}. {0. #'touchpad_x'}. {1. #'touchpad_y'}} collect: [:axis | | state subscriber |
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
						radius: 0.002)};
				ref: handArea.
			(self godot: #Spatial) ref: [:node | handPortal set: node]};
		button_pressed: buttonPressed;
		button_release: buttonRelase;
		subscribeTo: #transform do: transformSub.
	
	axes do: [:axis | controllerNode subscribeCall: 'get_joystick_axis' with: {axis first} do: axis fourth].
	
	^ {
		controllerNode.
		GRProvider
			values: {
				#controllerTransform -> transform get.
				#handPortal -> handPortal get.
				#handId -> handArea.
				#pressedButtons -> pressedButtons get}, (axes collect: [:axis | axis second -> axis third get])
			children: (props at: #children ifAbsent: [#()])}
]

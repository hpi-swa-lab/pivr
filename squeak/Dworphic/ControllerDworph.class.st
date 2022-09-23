Class {
	#name : #ControllerDworph,
	#superclass : #CMFReactComponent,
	#category : #Dworphic
}

{ #category : #'as yet unclassified' }
ControllerDworph >> render: props [

	| handPortal transform transformSub triggerStrength triggerStrengthSub buttonPressed buttonRelase pressedButtons controllerNode axes |
	handPortal := self useRef: nil.
	
	transform := self useState: Matrix4x4 identity.
	transformSub := self useCallback: [:t | transform set: t] dependencies: {}.
	
	axes := {{2. #trigger}. {7. #grip}. {0. #'touchpad_x'}. {1. #'touchpad_y'}} collect: [:axis | | state subscriber |
		state := self useState: 0.0.
		subscriber := self
			useCallback: [:s |
				Transcript showln: {axis second. s}.
				state set: s]
			dependencies: {}.
		axis, {state. subscriber}].
	triggerStrength := self useState: 0.0.
	triggerStrengthSub := self useCallback: [:s | triggerStrength set: s] dependencies: {}.
	
	pressedButtons := self useState: {}.
	buttonPressed := self
		useCallback: [:button | pressedButtons set: [:b | b copyWith: button]]
		dependencies: {}.
	buttonRelase := self
		useCallback: [:button | pressedButtons set: [:b | b copyWithout: button]]
		dependencies: {}.
	
	controllerNode := (self godot: #ARVRController)
		controller_id: ((props at: #left) == true ifTrue: [1] ifFalse: [2]);
		children: (props at: #children ifAbsent: [#()]), {(self godot: #Spatial) ref: [:node | handPortal set: node]};
		button_pressed: buttonPressed;
		button_release: buttonRelase;
		subscribeTo: #transform do: transformSub.
	
	axes do: [:axis | controllerNode subscribeCall: 'get_joystick_axis' with: {axis first} do: axis fourth].
	
	^ controllerNode
]

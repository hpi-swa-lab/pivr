Class {
	#name : #ControllerInfoDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
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

	| handPortal transform pressedButtons controllerNode axes handArea handIsFree |
	handPortal := self useRef: nil.
	handArea := self useRemoteRef.
	
	handIsFree := self useState: true.
	transform := self useState: Matrix4x4 identity.
	pressedButtons := self useState: {}.
	
	axes := {{self class triggerAxis. #trigger}. {7. #grip}. {0. #'touchpad_x'}. {1. #'touchpad_y'}} collect: [:axis | | state |
		state := self useState: 0.0.
		axis, {state. [:s | state set: s]}].
	
	controllerNode := (self godot: #ARVRController)
		controller_id: ((props at: #left) == true ifTrue: [1] ifFalse: [2]);
		children: {
			(self godot: #Area)
				children: {
					(self godot: #CollisionShape) shape: ((self godot: #SphereShape)
						margin: 0.001;
						radius: 0.005)};
				ref: handArea.
			(self godot: #Spatial) ref: handPortal.
			(self godot: #MeshInstance) mesh: ((self godot: #SphereMesh)
				radius: 0.005;
				height: 0.01)};
		button_pressed: [:button | pressedButtons set: [:b | b copyWith: button]];
		button_release: [:button | pressedButtons set: [:b | b copyWithout: button]];
		subscribeTo: #'global_transform' do: [:t | transform set: t].
	
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

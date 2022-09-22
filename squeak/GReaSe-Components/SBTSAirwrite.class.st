Class {
	#name : #SBTSAirwrite,
	#superclass : #CMFReactComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
SBTSAirwrite >> render: props [

	| controllerTranslation lastControllerTranslation curveRef buttonPressed wasPressed |
	lastControllerTranslation := self useState: Vector3 zero.
	controllerTranslation := (self useContext: SBTSRightControllerTransform) translation.
	buttonPressed := self useContext: SBTSRightJoystickPressed.
	curveRef := self useRef: nil.
	wasPressed := self useRef: false.
	
	self
		useEffect: [
			(buttonPressed not and: [wasPressed get]) ifTrue: [
				wasPressed set: false.
				GDCurrentSession value callOn: curveRef get method: 'clear_points' arguments: {}].
			
			(lastControllerTranslation get distanceTo: controllerTranslation) > 0.01 ifTrue: [
				lastControllerTranslation set: controllerTranslation.
				buttonPressed ifTrue: [
					wasPressed set: true.
					GDCurrentSession value
						callOn: curveRef get
						method: 'add_point'
						arguments: {controllerTranslation}]].
			nil]
		dependencies: {controllerTranslation. buttonPressed}.
	
	^ (self godot: #Spatial) children: {
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
]

Class {
	#name : #CubeRemoveDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Example'
}

{ #category : #'as yet unclassified' }
CubeRemoveDworph >> collisionShape [

	^ (self godot: #BoxShape) extents: (self size / 2.0) asVector3
]

{ #category : #'as yet unclassified' }
CubeRemoveDworph >> render: props [

	| cubes grabbed triggerPressed |
	cubes := self useProvided: #cubes.
	grabbed := self useState: false.
	triggerPressed := self useState: false.
	
	^ GRGrabbableArea new
		transform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		onGrab: [grabbed set: true];
		onRelease: [:event | grabbed set: false];
		onButtonPress: [:event | event isTrigger ifTrue: [triggerPressed set: true]];
		onButtonRelease: [:event | event isTrigger ifTrue: [triggerPressed set: false]];
		children: {
			GDCollisionShape new shape: self collisionShape.
			GDMeshInstance new mesh: (GDCubeMesh new
				size: self size asVector3;
				material: (GDSpatialMaterial new albedoColor: (Color r: 1 g: 0.0 b: 0.0))).
			grabbed get
				ifTrue: [
					GDArea new
						children: {GDCollisionShape new shape: self collisionShape};
						onAreaEntered: [:area | | id |
							id := (area grAsClass: #GDArea) getMetaName: 'id' default: 0.
							(triggerPressed get and: [id ~~ 0]) ifTrue: [
								cubes set: [:c |
									self assert: (c anySatisfy: [:cube | cube third = id]).
									c select: [:cube | cube third ~= id]]]]]
				ifFalse: [nil]}
]

{ #category : #'as yet unclassified' }
CubeRemoveDworph >> size [

	^ 0.03
]

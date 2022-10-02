Class {
	#name : #CubeDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
CubeDworph >> render: props [

	| renderMesh |
	renderMesh := [
		(self godot: #MeshInstance) mesh: ((self godot: #CubeMesh)
			size: 0.1 @ 0.1 @ 0.1;
			material: ((self godot: #SpatialMaterial) albedo_color: (props at: #color)))].
	^ ControllerToolDworph new
		transform: (props at: #transform);
		onRelease: #drop;
		id: (props at: #id ifAbsent: nil);
		shape: ((self godot: #BoxShape) extents: 0.05 @ 0.05 @ 0.05);
		active: renderMesh;
		passive: renderMesh
]

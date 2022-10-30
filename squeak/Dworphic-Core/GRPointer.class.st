Class {
	#name : #GRPointer,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
GRPointer >> render: props [

	| overlappingAreas |
	overlappingAreas := self useState: OrderedCollection new.

	^ GRActingArea new
		side: (props at: #side ifAbsent: [#none]);
		actingTransform: (props at: #transform ifAbsent: [Matrix4x4 identity]);
		controllerRef: (props at: #controllerRef ifAbsent: [nil]);
		type: #point;
		setHandlers: (props at: #setHandlers);
		children: {
			GDCollisionShape new
				rotation: 0 @ Float pi @ 0;
				shape: (GDRayShape new
					length: 3).
			GDArea new
				onAreaEntered: [:area | 
					((GDArea new objectId: area objectId) getMetaName: #allowsPointing default: false)
						ifTrue: [overlappingAreas set: [:old | old copyWith: area]]];
				onAreaExited: [:area |
					((GDArea new objectId: area objectId) getMetaName: #allowsPointing default: false)
						ifTrue: [overlappingAreas set: [:old | old copyRemove: area]]];
				rotation: Float pi / 2 @ 0 @ 0;
				translation: 0 @ 0 @ -1.5;
				children: {
					GDCollisionShape new
						shape: (GDCylinderShape new
							height: 3;
							radius: 0.1)}.
			GDMeshInstance new
				visible: overlappingAreas get notEmpty;
				rotation: Float pi / 2 @ 0 @ 0;
				translation: 0 @ 0 @ -1.5;
				mesh: (GDCylinderMesh new
					height: 3;
					topRadius: 0.005;
					bottomRadius: 0.005;
					material: (GDSpatialMaterial new
						albedoColor: Color red))}
]

Class {
	#name : #BlockCodeTool,
	#superclass : #GRComponent,
	#category : #'Dworphic-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeTool >> render: props [

	^ GRDraggableArea new
		touch: true;
		point: false;
		children: {
			GDCollisionShape new
				shape: (GDCylinderShape new
					height: 20cm;
					radius: 1cm).
			GDMeshInstance new
				mesh: (GDCylinderMesh new
					height: 20cm;
					bottomRadius: 2mm;
					topRadius: 1cm)}
]

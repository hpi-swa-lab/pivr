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
			GDMeshInstance new
				mesh: (GDCylinderMesh new
					height: 20 centimeter;
					bottomRadius: 5 centimeter;
					topRadius: 1 centimeter)}
]

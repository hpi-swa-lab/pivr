Class {
	#name : #SphereHand,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
SphereHand >> render: props [

	^ GDMeshInstance new
		scale: 0.1 asVector3;
		mesh: GDSphereMesh new
]
Class {
	#name : #BlockCodeExampleFlat,
	#superclass : #BlockCodeExample,
	#category : #'Dworphic-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeExampleFlat >> interactionComponent [

	^ GDSpatial new
		children: {
			FlyingCam new.
			"GRRerenderEnforcer new"}
]

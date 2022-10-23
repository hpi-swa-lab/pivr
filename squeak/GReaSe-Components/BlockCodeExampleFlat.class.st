Class {
	#name : #BlockCodeExampleFlat,
	#superclass : #BlockCodeExample,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeExampleFlat >> interactionComponent [

	^ GDSpatial new
		children: {
			FlyingCam new.
			"GRRerenderEnforcer new"}
]

Class {
	#name : #BlockCodeExampleFlat,
	#superclass : #BlockCodeExample,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeExampleFlat >> interactionComponent [

	^ FlyingCam asReactNodeBuilder build.
]

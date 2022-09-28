Class {
	#name : #BlockCodeExampleVR,
	#superclass : #BlockCodeExample,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeExampleVR >> editorTranslation [

	^ 0 @ 1 @ 0
]

{ #category : #'as yet unclassified' }
BlockCodeExampleVR >> interactionComponent [

	^ WorldDworph asReactNodeBuilder build
]

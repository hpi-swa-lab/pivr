Class {
	#name : #DworphicApplicationDescription,
	#superclass : #Object,
	#instVars : [
		'name',
		'appClass',
		'id',
		'properties',
		'render',
		'priority',
		'renderHand',
		'renderController',
		'rendersEnvironment'
	],
	#classVars : [
		'NextId'
	],
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> buildComponent [

	^ render value
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> hasRenderController [

	^ renderController notNil
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> hasRenderHand [

	^ renderHand notNil
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> initialize [

	id := NextId ifNil: [NextId := 0] ifNotNil: [NextId := NextId + 1].
	properties := Dictionary new.
	priority := 0.
	rendersEnvironment := false
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> name [

	^ name ifNil: ['Unnamed application']
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> name: aString [

	name := aString
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> priority [

	^ priority ifNil: [0]
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> priority: aNumber [

	priority := aNumber
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> render [

	^ render
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> render: aBlock [

	render := aBlock
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> renderController [

	^ renderController
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> renderController: aBlock [

	renderController := aBlock
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> renderHand [

	^ renderHand
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> renderHand: aBlock [

	renderHand := aBlock
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> rendersEnvironment [

	^ rendersEnvironment
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> rendersEnvironment: aBoolean [

	rendersEnvironment := aBoolean
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> toolPriority [

	priority := -1
]

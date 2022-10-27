Class {
	#name : #DworphicApplicationDescription,
	#superclass : #Object,
	#instVars : [
		'name',
		'appClass',
		'id',
		'properties',
		'render',
		'handComponent',
		'priority'
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
DworphicApplicationDescription >> handComponent [
	
	^ handComponent
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> handComponent: aBlock [

	handComponent := aBlock
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> hasHandComponent [

	^ handComponent notNil
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> initialize [

	id := NextId ifNil: [NextId := 0] ifNotNil: [NextId := NextId + 1].
	properties := Dictionary new
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

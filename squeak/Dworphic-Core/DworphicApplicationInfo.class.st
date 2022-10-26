Class {
	#name : #DworphicApplicationInfo,
	#superclass : #Object,
	#instVars : [
		'name',
		'appClass',
		'id',
		'config'
	],
	#classVars : [
		'NextId'
	],
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
DworphicApplicationInfo >> appClass [

	^ appClass
]

{ #category : #'as yet unclassified' }
DworphicApplicationInfo >> appClass: aClass [

	appClass := aClass
]

{ #category : #'as yet unclassified' }
DworphicApplicationInfo >> buildComponent [

	 ^ appClass new
		props: self config;
		key: id
]

{ #category : #'as yet unclassified' }
DworphicApplicationInfo >> config [

	^ config ifNil: [Dictionary new]
]

{ #category : #'as yet unclassified' }
DworphicApplicationInfo >> config: aPropsDictionary [

	config := aPropsDictionary
]

{ #category : #'as yet unclassified' }
DworphicApplicationInfo >> initialize [

	id := (NextId ifNil: [0] ifNotNil: [NextId := NextId + 1])
]

{ #category : #'as yet unclassified' }
DworphicApplicationInfo >> name [

	^ name
]

{ #category : #'as yet unclassified' }
DworphicApplicationInfo >> name: aString [

	name := aString
]

Class {
	#name : #DworphicApplicationDescription,
	#superclass : #Object,
	#instVars : [
		'name',
		'appClass',
		'id',
		'properties'
	],
	#classVars : [
		'NextId'
	],
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> appClass [

	^ appClass
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> appClass: aClass [

	appClass := aClass
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> buildComponent [

	 ^ appClass new
		props: properties;
		key: id
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> doesNotUnderstand: aMessage [

	| key |
	key := aMessage selector.
	(key precedence = 3 and: [(key indexOf: $:) = key size]) ifTrue: [ | value prop |
		prop := key allButLast asSymbol.
		value := aMessage arguments first.
		value isGodotNode ifTrue: [
			value isResource: true.
			value godotId: prop].
		properties at: prop put: value.
		^ self].
	^ super doesNotUnderstand: aMessage
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> initialize [

	id := (NextId ifNil: [0] ifNotNil: [NextId := NextId + 1]).
	properties := Dictionary new.
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> name [

	^ name
]

{ #category : #'as yet unclassified' }
DworphicApplicationDescription >> name: aString [

	name := aString
]

Class {
	#name : #GRMockSession,
	#superclass : #Object,
	#instVars : [
		'replies'
	],
	#category : #'GReaSe-Test'
}

{ #category : #'as yet unclassified' }
GRMockSession >> callOn: anObject method: aSymbol arguments: aCollection [

	| index |
	index := replies findFirst: [:reply | reply key = aSymbol].
	index > 0 ifTrue: [^ (replies removeAt: index) value].
	^ nil
]

{ #category : #'as yet unclassified' }
GRMockSession >> for: aMethodSymbol reply: anObject [

	replies add: aMethodSymbol -> anObject
]

{ #category : #'as yet unclassified' }
GRMockSession >> get: aSymbol of: anObject [

	| index |
	index := replies findFirst: [:reply | reply key = aSymbol].
	index > 0 ifTrue: [^ (replies removeAt: index) value].
	^ nil
]

{ #category : #'as yet unclassified' }
GRMockSession >> initialize [

	super initialize.
	
	replies := OrderedCollection new
]

{ #category : #'as yet unclassified' }
GRMockSession >> set: aSymbol of: anObject to: anotherObject [

	
]

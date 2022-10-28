Class {
	#name : #GRMockSession,
	#superclass : #Object,
	#instVars : [
		'replies',
		'calls'
	],
	#category : #'GReaSe-Test'
}

{ #category : #'as yet unclassified' }
GRMockSession >> callOn: anObject method: aSymbol arguments: aCollection [

	| index |
	calls add: {anObject. aSymbol. aCollection}.
	index := replies findFirst: [:reply | reply key = aSymbol].
	index > 0 ifTrue: [^ (replies removeAt: index) value].
	^ nil
]

{ #category : #'as yet unclassified' }
GRMockSession >> calls [

	^ calls
]

{ #category : #'as yet unclassified' }
GRMockSession >> createInstanceOf: aGodotClass [

	^ GRObjectId new objectId: GRReact nextGodotId
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
	
	replies := OrderedCollection new.
	calls := OrderedCollection new
]

{ #category : #'as yet unclassified' }
GRMockSession >> set: aSymbol of: anObject to: anotherObject [

	calls add: {anObject. aSymbol. anotherObject}
]

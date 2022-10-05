Class {
	#name : #GRProvider,
	#superclass : #CMFReactNode,
	#instVars : [
		'children',
		'values',
		'namespace'
	],
	#category : #'GReaSe-React'
}

{ #category : #'as yet unclassified' }
GRProvider class >> namespace: aSymbol values: aDictionary children: aCollection [

	^ self new namespace: aSymbol values: aDictionary children: aCollection
]

{ #category : #'as yet unclassified' }
GRProvider class >> values: aDictionary children: aCollection [

	^ self new values: aDictionary children: aCollection
]

{ #category : #'as yet unclassified' }
GRProvider >> executeUserCode: react renderInfo: renderInfo [

	^ nil
]

{ #category : #'as yet unclassified' }
GRProvider >> get: aSymbol [

	^ values at: aSymbol
]

{ #category : #'as yet unclassified' }
GRProvider >> hasKey [

	^ false
]

{ #category : #'as yet unclassified' }
GRProvider >> hasSymbol: aSymbol [

	^ values includesKey: aSymbol
]

{ #category : #'as yet unclassified' }
GRProvider >> key [

	^ nil
]

{ #category : #'as yet unclassified' }
GRProvider >> namespace [

	^ namespace
]

{ #category : #'as yet unclassified' }
GRProvider >> namespace: aSymbol values: aDictionary children: aCollection [

	namespace := aSymbol.
	values := aDictionary isDictionary
		ifTrue: [aDictionary]
		ifFalse: [aDictionary as: Dictionary].
	children := aCollection
]

{ #category : #'as yet unclassified' }
GRProvider >> printOn: aStream [

	aStream nextPutAll: '<GRProvider />'
]

{ #category : #'as yet unclassified' }
GRProvider >> render: react renderInfo: renderInfo userCodeResult: userCodeResult [

	^ react renderNodes: children
]

{ #category : #'as yet unclassified' }
GRProvider >> type [

	^ {#grProvider}
]

{ #category : #'as yet unclassified' }
GRProvider >> values: aDictionary children: aCollection [

	values := aDictionary isDictionary
		ifTrue: [aDictionary]
		ifFalse: [aDictionary as: Dictionary].
	children := aCollection
]

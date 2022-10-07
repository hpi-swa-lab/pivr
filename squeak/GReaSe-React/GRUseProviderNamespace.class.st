Class {
	#name : #GRUseProviderNamespace,
	#superclass : #CMFReactNode,
	#instVars : [
		'children',
		'namespace'
	],
	#category : #'GReaSe-React'
}

{ #category : #'as yet unclassified' }
GRUseProviderNamespace class >> namespace: aSymbol children: aCollection [

	^ self new namespace: aSymbol children: aCollection
]

{ #category : #'as yet unclassified' }
GRUseProviderNamespace >> computeChildrenAndUpdate: aFiber for: aState caughtError: anErrorOrNil [

	^ children
]

{ #category : #'as yet unclassified' }
GRUseProviderNamespace >> executeUserCode: react renderInfo: renderInfo [

	^ nil
]

{ #category : #'as yet unclassified' }
GRUseProviderNamespace >> hasKey [

	^ false
]

{ #category : #'as yet unclassified' }
GRUseProviderNamespace >> key [

	^ nil
]

{ #category : #'as yet unclassified' }
GRUseProviderNamespace >> namespace [

	^ namespace
]

{ #category : #'as yet unclassified' }
GRUseProviderNamespace >> namespace: aSymbol children: aCollection [

	namespace := aSymbol.
	children := aCollection
]

{ #category : #'as yet unclassified' }
GRUseProviderNamespace >> printOn: aStream [

	aStream nextPutAll: '<GRUseProviderNamespace />'
]

{ #category : #'as yet unclassified' }
GRUseProviderNamespace >> render: react renderInfo: renderInfo userCodeResult: userCodeResult [

	^ react renderNodes: children
]

{ #category : #'as yet unclassified' }
GRUseProviderNamespace >> type [

	^ {#grUseNamespace}
]

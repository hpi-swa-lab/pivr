Class {
	#name : #GRHookUseProvidedRef,
	#superclass : #CMFReactHook,
	#instVars : [
		'symbol',
		'node',
		'lastValue',
		'namespace'
	],
	#category : #'GReaSe-React'
}

{ #category : #'as yet unclassified' }
GRHookUseProvidedRef >> get [

	| validNamespaces |
	validNamespaces := OrderedCollection with: namespace.
	^ (node orParentSatisfying: [:entry |
		entry node class == GRUseProviderNamespace ifTrue: [validNamespaces add: entry node namespace].
		entry node class == GRProvider and: [(validNamespaces includes: entry node namespace) and: [entry node hasSymbol: symbol]]])
		ifNotNil: [:entry | entry get: symbol]
		ifNil: [self error: ('no value for {1} provided in tree' format: {symbol})]
]

{ #category : #'as yet unclassified' }
GRHookUseProvidedRef >> namespace: aSymbol [

	namespace := aSymbol
]

{ #category : #'as yet unclassified' }
GRHookUseProvidedRef >> symbol: aSymbol node: aNode [

	symbol := aSymbol.
	node := aNode
]

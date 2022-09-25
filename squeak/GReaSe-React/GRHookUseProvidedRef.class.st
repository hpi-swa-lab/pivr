Class {
	#name : #GRHookUseProvidedRef,
	#superclass : #CMFReactHook,
	#instVars : [
		'symbol',
		'node',
		'lastValue'
	],
	#category : #'GReaSe-React'
}

{ #category : #'as yet unclassified' }
GRHookUseProvidedRef >> get [

	^ (node orParentSatisfying: [:entry | entry node class == GRProvider and: [entry node hasSymbol: symbol]])
		ifNotNil: [:entry | entry get: symbol]
		ifNil: [self error: ('no value for {1} provided in tree' format: {symbol})]
]

{ #category : #'as yet unclassified' }
GRHookUseProvidedRef >> symbol: aSymbol node: aNode [

	symbol := aSymbol.
	node := aNode
]

Class {
	#name : #GRHookUseProvided,
	#superclass : #CMFReactHook,
	#instVars : [
		'symbol',
		'node',
		'lastValue'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRHookUseProvided >> canTriggerRerender [

	^ true
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> getValueBasedOnNodeTree: aCMFReactNodeTree setLastValue: aBoolean [

	| newValue |
	newValue := (node orParentSatisfying: [:entry | entry node class == GRProvider and: [entry node hasSymbol: symbol]])
		ifNotNil: [:entry | entry get: symbol]
		ifNil: [self error: ('no value for {1} provided in tree' format: {symbol})].
	aBoolean ifTrue: [lastValue := newValue].
	^ newValue
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> isValueOutdatedBasedOnNodeTree: aCMFReactNodeTree [

	^ lastValue ~~ (self getValueBasedOnNodeTree: aCMFReactNodeTree setLastValue: false)
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> symbol: aSymbol node: aNode [

	symbol := aSymbol.
	node := aNode
]

Class {
	#name : #GRHookUseProvided,
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
GRHookUseProvided >> canTriggerRerender [

	^ true
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> getValueAndRemember: aBoolean [

	| newValue validNamespaces |
	validNamespaces := OrderedCollection with: namespace.
	newValue := (fiber orParentSatisfying: [:entry |
		entry node class == GRUseProviderNamespace ifTrue: [validNamespaces add: entry node namespace].
		entry node class == GRProvider and: [(validNamespaces includes: entry node namespace) and: [entry node hasSymbol: symbol]]])
		ifNotNil: [:fiber | fiber node get: symbol]
		ifNil: [self error: ('no value for {1} provided in tree' format: {symbol})].
	aBoolean ifTrue: [lastValue := newValue].
	^ newValue
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> getValueBasedOnNodeTree: aCMFReactNodeTree setLastValue: aBoolean [

	| newValue validNamespaces |
	validNamespaces := OrderedCollection with: namespace.
	newValue := (node orParentSatisfying: [:entry |
		entry node class == GRUseProviderNamespace ifTrue: [validNamespaces add: entry node namespace].
		entry node class == GRProvider and: [(validNamespaces includes: entry node namespace) and: [entry node hasSymbol: symbol]]])
		ifNotNil: [:entry | entry node get: symbol]
		ifNil: [self error: ('no value for {1} provided in tree' format: {symbol})].
	aBoolean ifTrue: [lastValue := newValue].
	^ newValue
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> isValueOutdatedBasedOnNodeTree: aCMFReactNodeTree [

	^ lastValue ~~ (self getValueBasedOnNodeTree: aCMFReactNodeTree setLastValue: false)
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> namespace: aSymbol [

	namespace := aSymbol
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> symbol: aSymbol node: aNode [

	symbol := aSymbol.
	node := aNode
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> valueOutdated [

	^ lastValue ~~ (self getValueAndRemember: false)
]

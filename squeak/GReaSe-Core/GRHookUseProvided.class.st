Class {
	#name : #GRHookUseProvided,
	#superclass : #CMFReactHook,
	#instVars : [
		'symbol',
		'nodeId',
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

	| treeEntry newValue |
	treeEntry := aCMFReactNodeTree rootEntry findTreeNodeById: nodeId.
	newValue := (treeEntry orParentSatisfying: [:entry | entry node class == GRProvider and: [entry node hasSymbol: symbol]]) ifNotNil: [:entry | entry get: symbol].
	aBoolean ifTrue: [lastValue := newValue].
	^ newValue
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> isValueOutdatedBasedOnNodeTree: aCMFReactNodeTree [

	^ lastValue ~~ (self getValueBasedOnNodeTree: aCMFReactNodeTree setLastValue: false)
]

{ #category : #'as yet unclassified' }
GRHookUseProvided >> symbol: aSymbol nodeId: aNodeId [

	symbol := aSymbol.
	nodeId := aNodeId
]

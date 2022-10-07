Class {
	#name : #GRHookUseRemoteRef,
	#superclass : #CMFReactHook,
	#instVars : [
		'state',
		'hostConfig',
		'godotClass'
	],
	#category : #'GReaSe-React'
}

{ #category : #public }
GRHookUseRemoteRef >> get [

	^ godotClass ifNotNil: [state grAsClass: godotClass] ifNil: [state]
]

{ #category : #private }
GRHookUseRemoteRef >> hostConfig: aHost [

	hostConfig := aHost
]

{ #category : #private }
GRHookUseRemoteRef >> set: aNode [

	state := aNode
]

{ #category : #private }
GRHookUseRemoteRef >> value: anObject [

	godotClass := anObject isArray ifTrue: [(Smalltalk classNamed: 'GD', anObject fifth) ifNotNil: ['GD', anObject fifth]].
	hostConfig
		addRef: self
		for: (anObject isArray ifTrue: [anObject] ifFalse: [anObject godotPath])
]

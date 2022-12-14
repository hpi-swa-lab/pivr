Class {
	#name : #GRHookUseGodotRef,
	#superclass : #CMFReactHook,
	#instVars : [
		'state',
		'hostConfig',
		'godotClass'
	],
	#category : #'GReaSe-React'
}

{ #category : #public }
GRHookUseGodotRef >> get [

	^ godotClass ifNotNil: [state grAsClass: godotClass] ifNil: [state]
]

{ #category : #private }
GRHookUseGodotRef >> hostConfig: aHost [

	hostConfig := aHost
]

{ #category : #public }
GRHookUseGodotRef >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	state objectId printOn: aStream.
	aStream nextPut: $).
]

{ #category : #private }
GRHookUseGodotRef >> set: aNode [

	state := aNode
]

{ #category : #private }
GRHookUseGodotRef >> value: anObject [

	godotClass := anObject isArray ifTrue: [(Smalltalk classNamed: 'GD', anObject fifth) ifNotNil: ['GD', anObject fifth]].
	hostConfig
		addRef: self
		for: (anObject isArray ifTrue: [anObject] ifFalse: [anObject godotPath])
]

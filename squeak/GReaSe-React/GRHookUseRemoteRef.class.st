Class {
	#name : #GRHookUseRemoteRef,
	#superclass : #CMFReactHook,
	#instVars : [
		'state',
		'hostConfig'
	],
	#category : #'GReaSe-React'
}

{ #category : #public }
GRHookUseRemoteRef >> get [

	^ state
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

	hostConfig addRef: self for: anObject
]

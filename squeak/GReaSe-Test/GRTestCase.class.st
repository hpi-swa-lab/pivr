Class {
	#name : #GRTestCase,
	#superclass : #TestCase,
	#instVars : [
		'godotTree',
		'react'
	],
	#category : #'GReaSe-Test'
}

{ #category : #'as yet unclassified' }
GRTestCase >> controllerCollider: aSideSymbol [

	^ GRObjectId new objectId: ((self controllerNode: aSideSymbol) firstNodeOfType: #Area) path
]

{ #category : #'as yet unclassified' }
GRTestCase >> controllerNode: aSideSymbol [

	^ godotTree firstNodeThat: [:node | node godotClass = #ARVRController and: [(node properties at: #'controller_id') = (aSideSymbol = #left ifTrue: [1] ifFalse: [2])]]
]

{ #category : #'as yet unclassified' }
GRTestCase >> godot: aClassName [

	^ GRReactNodeGodot new
		godotClass: aClassName;
		yourself
]

{ #category : #'as yet unclassified' }
GRTestCase >> openComponent: aComponentClass [

	react := GRReact new
		session: GRMockSession new;
		init: aComponentClass new.
	godotTree := GRMockNode new.
	self tick
]

{ #category : #'as yet unclassified' }
GRTestCase >> openComponentBlock: aBlock [

	react := GRReact new
		session: GRMockSession new;
		init: aBlock asReactNodeBuilder build.
	godotTree := GRMockNode new.
	
	react session for: 'find_interface' reply: (GDARVRInterface basicNew objectId: 1).
	react session for: 'initialize' reply: true.
	react session for: 'get_main_loop' reply: (GDSceneTree basicNew objectId: 2).
	react session for: 'root' reply: (GDViewport basicNew objectId: 2).
	
	self tick
]

{ #category : #'as yet unclassified' }
GRTestCase >> tick [

	^ self tick: {}
]

{ #category : #'as yet unclassified' }
GRTestCase >> tick: aCollectionOfUpdates [

	^ godotTree tick: react updates: aCollectionOfUpdates asOrderedCollection
]

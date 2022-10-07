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
GRTestCase >> openComponent: aBlockOrClass [

	| component |
	component := aBlockOrClass isBlock
		ifTrue: [aBlockOrClass asComponent]
		ifFalse: [aBlockOrClass new].
	react := GRReact useFibers
		ifTrue: [
			(Smalltalk at: #CMFReactWithFibers) new
				hostConfig: (CMFHostConfigGodot new session: GRMockSession new);
				renderRoot: component in: {#add. ''. false. ''}]
		ifFalse: [
			GRReact new
				session: GRMockSession new;
				init: component].
	
	godotTree := GRMockNode new.
	
	react hostConfig session
		for: 'find_interface' reply: (GDARVRInterface basicNew objectId: 1);
		for: 'initialize' reply: true;
		for: 'get_main_loop' reply: (GDSceneTree basicNew objectId: 2);
		for: 'root' reply: (GDViewport basicNew objectId: 2).
	
	self tick
]

{ #category : #'as yet unclassified' }
GRTestCase >> openComponentBlock: aBlockOrClass [

	^ self openComponent: aBlockOrClass
]

{ #category : #'as yet unclassified' }
GRTestCase >> tick [

	^ self tick: {}
]

{ #category : #'as yet unclassified' }
GRTestCase >> tick: aCollectionOfUpdates [

	^ godotTree tick: react updates: aCollectionOfUpdates asOrderedCollection
]

Class {
	#name : #GRReactTest,
	#superclass : #TestCase,
	#instVars : [
		'godotTree',
		'react'
	],
	#category : #'GReaSe-Test'
}

{ #category : #'as yet unclassified' }
GRReactTest >> openComponent: aComponentClass [

	react := GRReact new
		session: GRMockSession new;
		init: aComponentClass new.
	godotTree := GRMockNode new.
	self tick
]

{ #category : #'as yet unclassified' }
GRReactTest >> openComponentBlock: aBlock [

	react := GRReact new
		session: GRMockSession new;
		init: aBlock asReactNodeBuilder build.
	godotTree := GRMockNode new.
	self tick
]

{ #category : #'as yet unclassified' }
GRReactTest >> testConditionalReplace [

	self openComponentBlock: [:props | | active |
		active := CMFReact useState: false.
		{
			(GRReactNodeGodot for: #Button) pressed: [active set: [:b | b not]].
			active get
				ifTrue: [(GRReactNodeGodot for: #Label) children: {GRReactNodeGodot for: #Child}]
				ifFalse: [GRReactNodeGodot for: #Spatial]}].
	
	godotTree firstNodeOfType: #Spatial.
	
	self tick: {(godotTree firstNodeOfType: #Button) trigger: #pressed}.
	
	godotTree firstNodeOfType: #Label.
	self should: [godotTree firstNodeOfType: #Spatial] raise: Error
]

{ #category : #'as yet unclassified' }
GRReactTest >> testGrabTool [

	self openComponent: GRExampleVR.
	
	self
		should: [(godotTree firstNodeOfType: #ARVRController) firstNodeOfType: #MeshInstance]
		raise: Error.
	
	self tick: {
		(godotTree firstNodeOfType: #ARVRController)
			trigger: #'button_pressed'
			with: {6}}.
	self tick: {
		(godotTree firstNodeThat: [:node | node properties includesKey: #'area_entered'])
			trigger: #'area_entered'
			with: {6}}.
	self
		shouldnt: [(godotTree firstNodeOfType: #ARVRController) firstNodeOfType: #MeshInstance]
		raise: Error.
	
	self tick: {
		(godotTree firstNodeOfType: #ARVRController)
			trigger: #'button_release'
			with: {6}}.
	self
		should: [(godotTree firstNodeOfType: #ARVRController) firstNodeOfType: #MeshInstance]
		raise: Error
]

{ #category : #'as yet unclassified' }
GRReactTest >> tick [

	^ self tick: {}
]

{ #category : #'as yet unclassified' }
GRReactTest >> tick: aCollectionOfUpdates [

	^ godotTree tick: react updates: aCollectionOfUpdates
]

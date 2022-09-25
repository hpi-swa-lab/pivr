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
GRReactTest >> godot: aClassName [

	^ GRReactNodeGodot new
		godotClass: aClassName;
		yourself
]

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
			(self godot: #Button) pressed: [active set: [:b | b not]].
			active get
				ifTrue: [(self godot: #Label) children: {self godot: #Child}]
				ifFalse: [self godot: #Spatial]}].
	
	godotTree firstNodeOfType: #Spatial.
	
	self tick: {(godotTree firstNodeOfType: #Button) trigger: #pressed}.
	
	godotTree firstNodeOfType: #Label.
	self should: [godotTree firstNodeOfType: #Spatial] raise: Error
]

{ #category : #'as yet unclassified' }
GRReactTest >> testReleaseToolStayOrReturn [

	| releasePos initialPos |
	initialPos := 1 @ 2 @ 3.
	releasePos := 4 @ 5 @ 6.
	{{#stay. releasePos}. {#return. initialPos}} do: [:pair |
		self openComponentBlock: [
			WorldDworph new children: {
				ControllerToolDworph new
					shape: (self godot: #CollisionShape);
					transform: (Matrix4x4 withOffset: initialPos);
					onRelease: pair first;
					active: [self godot: #Active];
					passive: [self godot: #Passive]}].
		self tick: {
			(godotTree firstNodeOfType: #ARVRController)
				trigger: #'button_pressed'
				with: {6}.
			(godotTree firstNodeThat: [:node | node properties includesKey: #'area_entered'])
				trigger: #'area_entered'
				with: {6}.
			(godotTree firstNodeOfType: #ARVRController)
				trigger: 'subscribe_transform'
				with: {Matrix4x4 withOffset: releasePos}}.
		self tick: {
			(godotTree firstNodeOfType: #ARVRController)
				trigger: #'button_release'
				with: {6}}.
		self
			assert: pair second
			equals: ((godotTree firstNodeOfType: #Passive) parent properties at: #transform) translation]
]

{ #category : #'as yet unclassified' }
GRReactTest >> testUnregistersCallbacks [

	self openComponentBlock: [(self godot: #Button) pressed: []].
	self assert: 1 equals: (react instVarNamed: #callbacks) size.
	self tick.
	self tick.
	self tick.
	Smalltalk garbageCollectMost.
	(react instVarNamed: #callbacks) clean.
	self assert: 2 equals: (react instVarNamed: #callbacks) size
]

{ #category : #'as yet unclassified' }
GRReactTest >> tick [

	^ self tick: {}
]

{ #category : #'as yet unclassified' }
GRReactTest >> tick: aCollectionOfUpdates [

	^ godotTree tick: react updates: aCollectionOfUpdates
]

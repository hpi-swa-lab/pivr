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
GRReactTest >> testAssignsRefBeforeEffects [

	self openComponentBlock: [ | ref |
		ref := CMFReact useRef: nil.
		CMFReact
			useEffect: [
				self assert: ref get notNil.
				nil]
			dependencies: {}.
		(self godot: #Spatial) ref: ref]
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
GRReactTest >> testDeleteInKeyedCollection [

	| data |
	data := {1. 2. 3. 4}.
	self openComponentBlock: [ | list |
		list := CMFReact useState: data.
		(self godot: #Spatial) children: (list get collect: [:id |
			(self godot: #Child)
				key: id;
				id: id;
				onDelete: [list set: [:l | l copyWithout: id]]])].
	self assert: 4 equals: (godotTree allNodesOfType: #Child) size.
	self tick: {(godotTree allNodesOfType: #Child) second trigger: #onDelete}.
	self
		assert: #(1 3 4)
		equals: ((godotTree allNodesOfType: #Child) collect: [:node | node properties at: #id]).
	
	self tick: {(godotTree allNodesOfType: #Child) first trigger: #onDelete}.
	self
		assert: #(3 4)
		equals: ((godotTree allNodesOfType: #Child) collect: [:node | node properties at: #id]).
	
	self tick: {(godotTree allNodesOfType: #Child) last trigger: #onDelete}.
	self
		assert: #(3)
		equals: ((godotTree allNodesOfType: #Child) collect: [:node | node properties at: #id])
]

{ #category : #'as yet unclassified' }
GRReactTest >> testLoopWithKeyedObjects [

	| nestedComponent |
	nestedComponent := [ | count callback |
		count := CMFReact useState: 0.
		callback := CMFReact useCallback: [count set: [:x | x + 1]] dependencies: {}.
		(self godot: (count get = 0 ifTrue: [#MeshInstance] ifFalse: [#RigidBody]))
			mesh: (self godot: #CubeMesh);
			pressed: callback].
	self openComponentBlock: [
		(self godot: #Spatial) children: ((1 to: 10) withIndexCollect: [:num :index |
			nestedComponent asReactNodeBuilder
				props: {#key -> index};
				build])].
	self assert: (self tick: {(godotTree firstNodeOfType: #MeshInstance) trigger: #pressed}) first size = 3
]

{ #category : #'as yet unclassified' }
GRReactTest >> testOptionalChildDirectInPortal [

	self openComponentBlock: [ | count portal |
		count := CMFReact useState: 0.
		portal := CMFReact useRef: nil.
		CMFReact
			useEffect: [count set: [:c | c = 1 ifTrue: [c + 1] ifFalse: [c]]]
			dependencies: {count get}.
		{
			(self godot: #Other)
				key: #other;
				ref: [:node | portal set: node].
			count get < 2 ifTrue: [
				(self godot: #Spatial)
					key: #Spatial;
					pressed: [count set: [:c | c + 1]];
					children: {
						[
							count get = 0
								ifTrue: [
									{
										self godot: #Child1.
										self godot: #Child2.
										CMFReactNodePortal child: (self godot: #OptionalChild) in: portal}]
								ifFalse: [{}]] asReactNodeBuilder build}]}].
	self assert: 1 equals: (godotTree firstNodeOfType: #Other) children size.
	self assert: 2 equals: (godotTree firstNodeOfType: #Spatial) children size.
	self tick: {(godotTree firstNodeOfType: #Spatial) trigger: #pressed}.
	self assert: 0 equals: (godotTree firstNodeOfType: #Spatial) children size.
	self assert: 0 equals: (godotTree firstNodeOfType: #Other) children size
]

{ #category : #'as yet unclassified' }
GRReactTest >> testOptionalChildNestedInPortal [

	self openComponentBlock: [ | count portal |
		count := CMFReact useState: 0.
		portal := CMFReact useRef: nil.
		{
			(self godot: #Other)
				key: #other;
				ref: [:node | portal set: node].
			(self godot: #Spatial)
				key: #Spatial;
				pressed: [count set: [:c | c + 1]];
				children: {
					self godot: #Child1.
					count get = 0
						ifTrue: [(self godot: #Nested) children: {CMFReactNodePortal child: (self godot: #OptionalChild) in: portal}]
						ifFalse: [nil].
					self godot: #Child2}}].
	self assert: 1 equals: (godotTree firstNodeOfType: #Other) children size.
	self assert: 3 equals: (godotTree firstNodeOfType: #Spatial) children size.
	self tick: {(godotTree firstNodeOfType: #Spatial) trigger: #pressed}.
	self assert: 2 equals: (godotTree firstNodeOfType: #Spatial) children size.
	self assert: 0 equals: (godotTree firstNodeOfType: #Other) children size
]

{ #category : #'as yet unclassified' }
GRReactTest >> testReleaseToolStayOrReturn [

	| releasePos initialPos |
	initialPos := 1 @ 2 @ 3.
	releasePos := 4 @ 5 @ 6.
	{{#return. initialPos}. {#stay. releasePos}} do: [:pair |
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

	^ godotTree tick: react updates: aCollectionOfUpdates asOrderedCollection
]

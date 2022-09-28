Class {
	#name : #GRReactTest,
	#superclass : #GRTestCase,
	#category : #'GReaSe-Test'
}

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
	
	self tick: {(godotTree firstNodeOfType: #Button) signal: #pressed}.
	
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
	self tick: {(godotTree allNodesOfType: #Child) second signal: #onDelete}.
	self
		assert: #(1 3 4)
		equals: ((godotTree allNodesOfType: #Child) collect: [:node | node properties at: #id]).
	
	self tick: {(godotTree allNodesOfType: #Child) first signal: #onDelete}.
	self
		assert: #(3 4)
		equals: ((godotTree allNodesOfType: #Child) collect: [:node | node properties at: #id]).
	
	self tick: {(godotTree allNodesOfType: #Child) last signal: #onDelete}.
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
	self assert: (self tick: {(godotTree firstNodeOfType: #MeshInstance) signal: #pressed}) first size = 3
]

{ #category : #'as yet unclassified' }
GRReactTest >> testNoRerenderOnSetInEffect [

	| once |
	once := true.
	self openComponentBlock: [ | state |
		state := CMFReact useState: 0.
		CMFReact
			useEffect: [
				self assert: once.
				state set: [:c | c + 1].
				once := false]
			dependencies: {}.
		nil].
	self tick.
	self tick
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
	self tick: {(godotTree firstNodeOfType: #Spatial) signal: #pressed}.
	self assert: 2 equals: (godotTree firstNodeOfType: #Spatial) children size.
	self assert: 0 equals: (godotTree firstNodeOfType: #Other) children size
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

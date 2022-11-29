Class {
	#name : #GRReactTest,
	#superclass : #GRTestCase,
	#category : #'GReaSe-Test'
}

{ #category : #failures }
GRReactTest >> expectedFailures [

	^ #(#testDoesNotOverwriteSharedCallback)
]

{ #category : #tests }
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

{ #category : #tests }
GRReactTest >> testChangingCallbackDoesNotCauseUpdate [

	| blockId |
	self openComponent: [(self godot: #Spatial) subscribeTo: #'global_transform' do: [:transform | ]].
	blockId := (godotTree firstNodeOfType: #Spatial) properties at: 'sqsubscribe_global_transform'.
	self tick.
	self
		assert: blockId
		equals: ((godotTree firstNodeOfType: #Spatial) properties at: 'sqsubscribe_global_transform')
]

{ #category : #tests }
GRReactTest >> testChangingSubCallDoesNotCauseUpdate [

	| blockId |
	self openComponent: [(self godot: #Spatial) subscribeCall: 'get_joystick_axis' with: {1} do: [#other]].
	blockId := ((godotTree firstNodeOfType: #Spatial) properties at: 'sqsubcall_get_joystick_axis_0') first.
	self tick.
	self
		assert: blockId
		equals: ((godotTree firstNodeOfType: #Spatial) properties at: 'sqsubcall_get_joystick_axis_0') first
]

{ #category : #tests }
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

{ #category : #tests }
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

{ #category : #tests }
GRReactTest >> testDisablesRenderingOnError [

	| changeWithError session |
	changeWithError := false.
	
	self openComponentBlock: [ | state |
		state := CMFReact useState: 0.
		changeWithError ifTrue: [self error].
		(self godot: #Timer) timeout: [state set: [:s | s + 1]]].
	session := GRTestSocketSession new
		react: react;
		socketStream: (ReadWriteStream on: ByteArray new).
	
	session handleRenderMessage: {0. 0. {ByteArray streamContents: [:stream | ((godotTree firstNodeOfType: #Timer) signal: #timeout) putVariantOn: stream]}}.
	changeWithError := true.
	self
		should: [session handleRenderMessage: {0. 0. {ByteArray streamContents: [:stream | ((godotTree firstNodeOfType: #Timer) signal: #timeout) putVariantOn: stream]}}]
		raise: Error.
	self
		shouldnt: [session handleRenderMessage: {0. 0. {ByteArray streamContents: [:stream | ((godotTree firstNodeOfType: #Timer) signal: #timeout) putVariantOn: stream]}}]
		raise: Error.
	
	session codeChanged: (AddedEvent class: self class category: 'GReaSe-Test').
	self
		should: [session handleRenderMessage: {0. 0. {ByteArray streamContents: [:stream | ((godotTree firstNodeOfType: #Timer) signal: #timeout) putVariantOn: stream]}}]
		raise: Error
]

{ #category : #tests }
GRReactTest >> testDoesNotOverwriteSharedCallback [

	| switchOne |
	switchOne := false.
	self openComponent: [ | callback |
		callback := [:transform | #original].
		{
			(self godot: #Spatial) subscribeTo: #'global_transform' do: callback.
			(self godot: #Other)
				subscribeTo: #'global_transform'
				do: (switchOne ifTrue: [[:other | #other]] ifFalse: [callback])}].
	
	self
		assert: #original
		equals: ((react hostConfig callbackFor: ((godotTree firstNodeOfType: #Spatial) properties at: 'sqsubscribe_global_transform')) value: 1).
	
	switchOne := true.
	self tick.
	self
		assert: #original
		equals: ((react hostConfig callbackFor: ((godotTree firstNodeOfType: #Spatial) properties at: 'sqsubscribe_global_transform')) value: 1)
]

{ #category : #tests }
GRReactTest >> testInsertInNestedComponent [

	self openComponentBlock: [ | toggle |
		toggle := CMFReact useState: false.
		(self godot: #VBoxContainer) children: {
			toggle get
				ifTrue: [[(self godot: #Label) text: 'a'] asComponent]
				ifFalse: [(self godot: #Label) text: 'a'].
			(self godot: #Label) text: 'b'.
			(self godot: #Timer) timeout: [toggle set: [:t | t not]]}].
	
	self assert: #('a' 'b') equals: ((godotTree allNodesOfType: #Label) collect: [:l | l text]).
	self tick: {(godotTree firstNodeOfType: #Timer) signal: #timeout}.
	self assert: #('a' 'b') equals: ((godotTree allNodesOfType: #Label) collect: [:l | l text])
]

{ #category : #tests }
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
	self
		assert: 3
		equals: (self tick: {(godotTree firstNodeOfType: #MeshInstance) signal: #pressed}) first size
]

{ #category : #tests }
GRReactTest >> testNoChangesMadeOnError [

	| changeWithError session |
	changeWithError := false.
	
	self openComponentBlock: [
		{
			changeWithError ifTrue: [self godot: #NewNode] ifFalse: [nil].
			[(self godot: #Other) field: (changeWithError ifTrue: [self error] ifFalse: [1])] asComponent}].
	session := GRTestSocketSession new
		react: react;
		socketStream: (WriteStream on: ByteArray new).
	
	changeWithError := true.
	self should: [self tick] raise: Error.
	react elementTree allEntriesDo: [:entry | (entry node isGodotNode and: [entry node godotClass = #NewNode]) ifTrue: [self assert: false]]
]

{ #category : #tests }
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

{ #category : #tests }
GRReactTest >> testOptionalChildNestedInPortal [

	self openComponentBlock: [ | count portal |
		count := CMFReact useState: 0.
		portal := CMFReact useRef: nil.
		{
			(self godot: #Portal)
				key: #portal;
				ref: portal.
			(self godot: #Spatial)
				key: #Spatial;
				pressed: [count set: [:c | c + 1]];
				children: {
					self godot: #Child1.
					count get = 0
						ifTrue: [
							(self godot: #Nested)
								key: #nested;
								children: {CMFReactNodePortal child: (self godot: #OptionalChild) in: portal}]
						ifFalse: [nil].
					self godot: #Child2}}].
	self assert: 1 equals: (godotTree firstNodeOfType: #Portal) children size.
	self assert: 3 equals: (godotTree firstNodeOfType: #Spatial) children size.
	self tick: {(godotTree firstNodeOfType: #Spatial) signal: #pressed}.
	self assert: 2 equals: (godotTree firstNodeOfType: #Spatial) children size.
	self assert: 0 equals: (godotTree firstNodeOfType: #Portal) children size
]

{ #category : #tests }
GRReactTest >> testPortal [

	self openComponentBlock: [ | portal |
		portal := CMFReact useRef: nil.
		{(self godot: #Portal) ref: portal. CMFReactNodePortal child: (self godot: #Teleported) in: portal}].
	(godotTree firstNodeOfType: #Portal) firstNodeOfType: #Teleported
]

{ #category : #tests }
GRReactTest >> testPortalChange [

	| changed |
	changed := false.
	self openComponentBlock: [ | portal2 portal1 |
		portal1 := CMFReact useRef: nil.
		portal2 := CMFReact useRef: nil.
		{
			(self godot: #Portal1)
				ref: portal1;
				name: 'portal1'.
			(self godot: #Portal2)
				ref: portal2;
				name: 'portal2'.
			CMFReactNodePortal
				child: ((self godot: #Teleported) name: 'teleported')
				in: (changed ifTrue: [portal2] ifFalse: [portal1])}].
	(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Teleported.
	changed := true.
	self tick.
	self should: [(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Teleported] raise: Error.
	(godotTree firstNodeOfType: #Portal2) firstNodeOfType: #Teleported.
	changed := false.
	self tick
]

{ #category : #tests }
GRReactTest >> testPortalChangeAndUpdate [

	| changed |
	changed := false.
	self openComponentBlock: [ | portal2 portal1 |
		portal1 := CMFReact useRef: nil.
		portal2 := CMFReact useRef: nil.
		{
			(self godot: #Portal1)
				ref: portal1;
				name: 'portal1'.
			(self godot: #Portal2)
				ref: portal2;
				name: 'portal2'.
			CMFReactNodePortal
				child: (((self godot: #Teleported) name: 'teleported') children: {(self godot: #Child) prop: (changed ifTrue: [2] ifFalse: [1])})
				in: (changed ifTrue: [portal2] ifFalse: [portal1])}].
	(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Teleported.
	changed := true.
	self tick.
	self should: [(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Teleported] raise: Error.
	(godotTree firstNodeOfType: #Portal2) firstNodeOfType: #Teleported
]

{ #category : #tests }
GRReactTest >> testPortalChangeAndUpdateResources [

	| changed |
	changed := false.
	self openComponentBlock: [ | portal2 portal1 |
		portal1 := CMFReact useRef: nil.
		portal2 := CMFReact useRef: nil.
		{
			(self godot: #Portal1)
				ref: portal1;
				name: 'portal1'.
			(self godot: #Portal2)
				ref: portal2;
				name: 'portal2'.
			CMFReactNodePortal
				child: (((self godot: #Teleported) name: 'teleported') children: {(self godot: #Child) material: ((self godot: #Material) prop: (changed ifTrue: [2] ifFalse: [1]))})
				in: (changed ifTrue: [portal2] ifFalse: [portal1])}].
	(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Teleported.
	changed := true.
	self tick.
	self should: [(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Teleported] raise: Error.
	(godotTree firstNodeOfType: #Portal2) firstNodeOfType: #Teleported
]

{ #category : #tests }
GRReactTest >> testPortalChangeInComponent [

	| changed |
	changed := false.
	self openComponentBlock: [ | portal2 portal1 |
		portal1 := CMFReact useRef: nil.
		portal2 := CMFReact useRef: nil.
		{
			(self godot: #Portal1)
				ref: portal1;
				name: 'portal1'.
			(self godot: #Portal2)
				ref: portal2;
				name: 'portal2'.
			CMFReactNodePortal
				child: [((self godot: #Teleported) name: 'teleported') children: {(self godot: #Child) name: 'child'}] asComponent
				in: (changed ifTrue: [portal2] ifFalse: [portal1])}].
	(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Child.
	changed := true.
	self tick.
	self should: [(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Teleported] raise: Error.
	(godotTree firstNodeOfType: #Portal2) firstNodeOfType: #Child.
	
	changed := false.
	self tick.
	self should: [(godotTree firstNodeOfType: #Portal2) firstNodeOfType: #Teleported] raise: Error.
	(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Child
]

{ #category : #tests }
GRReactTest >> testPortalChangeWithChildren [

	| changed |
	changed := false.
	self openComponentBlock: [ | portal2 portal1 |
		portal1 := CMFReact useRef: nil.
		portal2 := CMFReact useRef: nil.
		{
			(self godot: #Portal1)
				ref: portal1;
				name: 'portal1'.
			(self godot: #Portal2)
				ref: portal2;
				name: 'portal2'.
			CMFReactNodePortal
				child: (((self godot: #Teleported) name: 'teleported') children: {(self godot: #Child) name: 'child'})
				in: (changed ifTrue: [portal2] ifFalse: [portal1])}].
	(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Child.
	changed := true.
	self tick.
	self should: [(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Teleported] raise: Error.
	(godotTree firstNodeOfType: #Portal2) firstNodeOfType: #Child
]

{ #category : #tests }
GRReactTest >> testPortalChangeWithNewChildren [

	| changed |
	changed := false.
	self openComponentBlock: [ | portal2 portal1 |
		portal1 := CMFReact useRef: nil.
		portal2 := CMFReact useRef: nil.
		{
			(self godot: #Portal1)
				ref: portal1;
				name: 'portal1'.
			(self godot: #Portal2)
				ref: portal2;
				name: 'portal2'.
			CMFReactNodePortal
				child: [
					{
						(self godot: #Teleported) name: 'teleported'.
						(self godot: #Nested) children: (changed ifTrue: [(self godot: #Child) name: 'child'])}] asComponent
				in: (changed ifTrue: [portal2] ifFalse: [portal1])}].
	(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Teleported.
	changed := true.
	self tick.
	self should: [(godotTree firstNodeOfType: #Portal1) firstNodeOfType: #Teleported] raise: Error.
	(godotTree firstNodeOfType: #Portal2) firstNodeOfType: #Child.
	changed := false.
	self tick.
	self should: [godotTree firstNodeOfType: #Child] raise: Error
]

{ #category : #tests }
GRReactTest >> testReloadWithHooks [

	| change |
	change := false.
	self openComponentBlock: [ | label |
		change ifTrue: [CMFReact useState: 2].
		label := CMFReact useState: 'initial'.
		(self godot: #Label)
			text: label get;
			click: [label set: 'changed']].
	self tick: {(godotTree firstNodeOfType: #Label) signal: #click}.
	self assert: 'changed' equals: (godotTree firstNodeOfType: #Label) text.
	
	change := true.
	react onCodeChanged.
	self tick.
	self assert: 'initial' equals: (godotTree firstNodeOfType: #Label) text
]

{ #category : #tests }
GRReactTest >> testReloadWithHooksAndRenderChange [

	| change |
	change := false.
	self openComponentBlock: [ | label |
		change ifTrue: [CMFReact useState: 2].
		label := CMFReact useState: 'initial'.
		(self godot: (change ifTrue: [#Other] ifFalse: [#Label]))
			text: label get;
			click: [label set: 'changed']].
	self tick: {(godotTree firstNodeOfType: #Label) signal: #click}.
	self assert: 'changed' equals: (godotTree firstNodeOfType: #Label) text.
	
	change := true.
	react onCodeChanged.
	self tick.
	self assert: 'initial' equals: (godotTree firstNodeOfType: #Other) text
]

{ #category : #tests }
GRReactTest >> testReloadWithHooksChangeType [

	| change |
	change := false.
	self openComponentBlock: [ | label |
		label := change ifTrue: [CMFReact useRef: 'change'] ifFalse: [CMFReact useState: 'initial'].
		(self godot: #Label)
			text: label get;
			click: [label set: 'changed']].
	self tick: {(godotTree firstNodeOfType: #Label) signal: #click}.
	self assert: 'changed' equals: (godotTree firstNodeOfType: #Label) text.
	
	change := true.
	react onCodeChanged.
	self tick.
	self assert: 'change' equals: (godotTree firstNodeOfType: #Label) text
]

{ #category : #'as yet unclassified' }
GRReactTest >> testRenderUpdateBatched [

	| renderCount doSetState |
	renderCount := 0.
	doSetState := false.
	self openComponent: [
		renderCount := renderCount + 1.
		(1 to: 5) collect: [:i |
			[ | s |
				s := CMFReact useState: 0.
				(self godot: #Timer) onTimeout: [doSetState ifTrue: [s set: [:c | c + 1]]]] asComponent]].
	self assert: 1 equals: renderCount.
	self tick: ((godotTree allNodesOfType: #Timer) collect: [:t | t signal: #onTimeout with: {}]).
	self assert: 1 equals: renderCount.
	
	doSetState := true.
	self tick: ((godotTree allNodesOfType: #Timer) collect: [:t | t signal: #onTimeout with: {}]).
	self assert: 2 equals: renderCount
]

{ #category : #tests }
GRReactTest >> testSetStateInUseEffect [

	| runs |
	runs := OrderedCollection new.
	self openComponentBlock: [ | state |
		state := CMFReact useState: nil.
		CMFReact
			useEffect: [
				runs add: #effect.
				state set: true.
				[runs add: #cleanup]]
			dependencies: {}].
	self assert: #(#effect) equals: runs asArray
]

{ #category : #tests }
GRReactTest >> testSetStateInUseEffectFromSetState [

	| runs |
	runs := OrderedCollection new.
	self openComponentBlock: [ | state visible |
		visible := CMFReact useState: false.
		state := CMFReact useState: nil.
		{
			(self godot: #Button) pressed: [visible set: true].
			visible get ifTrue: [
				[
					CMFReact
						useEffect: [
							runs add: #effect.
							state set: true.
							[runs add: #cleanup]]
						dependencies: {state get}.
					nil] asComponent]}].
	self tick: {(godotTree firstNodeOfType: #Button) signal: #pressed}.
	self assert: #(#effect #cleanup #effect) equals: runs asArray
]

{ #category : #tests }
GRReactTest >> testSetStateInUseEffectWithDep [

	| runs |
	runs := OrderedCollection new.
	self openComponentBlock: [ | state |
		state := CMFReact useState: nil.
		CMFReact
			useEffect: [
				runs add: #effect.
				state set: true.
				[runs add: #cleanup]]
			dependencies: {state get}].
	self assert: #(#effect #cleanup #effect) equals: runs asArray
]

{ #category : #tests }
GRReactTest >> testUnregistersCallbacks [

	| gone |
	gone := false.
	self openComponentBlock: [gone ifTrue: [nil] ifFalse: [(self godot: #Button) pressed: []]].
	self assert: 1 equals: (react hostConfig instVarNamed: #callbacks) size.
	self tick.
	gone := true.
	self tick.
	self tick.
	Smalltalk garbageCollectMost.
	(react hostConfig instVarNamed: #callbacks) clean.
	self assert: 0 equals: (react hostConfig instVarNamed: #callbacks) size
]

{ #category : #tests }
GRReactTest >> testUpdateCall [

	| update |
	update := false.
	self openComponent: [ | b |
		b := self godot: #Button.
		update
			ifTrue: [b call: 'grab_acquire' arguments: #()]
			ifFalse: [b call: 'grab_release' arguments: #()].
		b].
	self assert: #() equals: ((godotTree firstNodeOfType: #Button) properties at: 'sqcall_grab_release').
	update := true.
	self tick.
	self assert: nil equals: ((godotTree firstNodeOfType: #Button) properties at: 'sqcall_grab_release')
]

{ #category : #tests }
GRReactTest >> testUseEffectNoDependencies [

	| runs |
	runs := OrderedCollection new.
	self openComponentBlock: [
		CMFReact
			useEffect: [
				runs add: #effect.
				[runs add: #cleanup]]
			dependencies: {}].
	self assert: #(#effect) equals: runs asArray
]

{ #category : #tests }
GRReactTest >> testUseProvided [

	self openComponentBlock: [
		GRProvider values: {#a -> 2} children: {
			[ | count |
				count := GRComponent basicNew useProvided: #a.
				(self godot: #Label) text: count] asComponent}].
	self assert: 2 equals: (godotTree firstNodeOfType: #Label) text
]

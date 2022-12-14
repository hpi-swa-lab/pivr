Class {
	#name : #GRMockNode,
	#superclass : #Object,
	#instVars : [
		'godotClass',
		'properties',
		'name',
		'children',
		'parent'
	],
	#category : #'GReaSe-Test'
}

{ #category : #internal }
GRMockNode >> addChild: aNode [

	self assert: aNode parent isNil.
	children add: aNode.
	aNode parent: self
]

{ #category : #accessing }
GRMockNode >> allNodesDo: aBlock [

	aBlock value: self.
	self children do: [:child | child allNodesDo: aBlock]
]

{ #category : #accessing }
GRMockNode >> allNodesOfType: aSymbol [

	^ self allNodesThat: [:node | node godotClass = aSymbol]
]

{ #category : #accessing }
GRMockNode >> allNodesThat: aBlock [

	^ Array streamContents: [:stream | self allNodesDo: [:node | (aBlock value: node) ifTrue: [stream nextPut: node]]]
]

{ #category : #internal }
GRMockNode >> applyUpdate: anUpdate [
	"should only be called on the tree root"

	anUpdate first caseOf: {
		[#add] -> [ | parent node |
			parent := self getNodeForPath: anUpdate second.
			node := GRMockNode new
				godotClass: anUpdate fifth;
				properties: anUpdate sixth copy.
			anUpdate third ifTrue: [parent properties at: anUpdate fourth put: node] ifFalse: [
				parent addChild: node.
				node name: anUpdate fourth]].
		[#insert] -> [ | parent node |
			parent := self getNodeForPath: anUpdate second.
			node := GRMockNode new
				godotClass: anUpdate fifth;
				properties: anUpdate sixth copy.
			anUpdate third ifTrue: [parent properties at: anUpdate fourth put: node] ifFalse: [
				parent insertChild: node before: (self getNodeForPath: anUpdate seventh).
				node name: anUpdate fourth]].
		[#move] -> [ | parent current |
			current := self getNodeForPath: anUpdate second.
			parent := self getNodeForPath: anUpdate third.
			current delete.
			
			anUpdate size = 4
				ifTrue: [parent insertChild: current before: (self getNodeForPath: anUpdate fourth)]
				ifFalse: [parent addChild: current]].
		[#update] -> [
			(self getNodeForPath: anUpdate second) properties
				at: anUpdate third
				put: anUpdate fourth].
		[#delete] -> [(self getNodeForPath: anUpdate second) delete]}
]

{ #category : #internal }
GRMockNode >> applyUpdates: aCollection [

	aCollection first do: [:update | self applyUpdate: update]
]

{ #category : #accessing }
GRMockNode >> children [

	^ children
]

{ #category : #internal }
GRMockNode >> delete [

	self parent children remove: self.
	parent := nil
]

{ #category : #accessing }
GRMockNode >> doesNotUnderstand: aMessage [

	| key |
	"getter only, you are not supposed to set properties on the mock nodes"
	key := aMessage selector.
	key precedence = 1 ifTrue: [^ properties at: key].
	^ super doesNotUnderstand: aMessage
]

{ #category : #accessing }
GRMockNode >> firstNodeNamed: aString [

	self allNodesDo: [:node | node name = aString ifTrue: [^ node]].
	self error: 'no node found'
]

{ #category : #accessing }
GRMockNode >> firstNodeOfType: aSymbol [

	^ self firstNodeThat: [:node | node godotClass = aSymbol]
]

{ #category : #accessing }
GRMockNode >> firstNodeThat: aBlock [

	self allNodesDo: [:node | (aBlock value: node) ifTrue: [^ node]].
	self error: 'no node found'
]

{ #category : #accessing }
GRMockNode >> firstNodeWithProp: aString [

	^ self firstNodeThat: [:n | n properties includesKey: aString]
]

{ #category : #internal }
GRMockNode >> getNodeForPath: aPath [

	| current stream |
	current := self.
	aPath ifEmpty: [^ self].
	stream := aPath readStream.
	
	"upToAnyOf: reads over the delimiter, so we always refer to the last below"
	stream next.
	[stream atEnd] whileFalse: [ | type part |
		type := stream last.
		part := stream upToAnyOf: '/:'.
		type = $/ ifTrue: [current := current children detect: [:child | child name = part]].
		type = $: ifTrue: [current := current properties at: part]].
	^ current
]

{ #category : #accessing }
GRMockNode >> godotClass [

	^ godotClass
]

{ #category : #internal }
GRMockNode >> godotClass: aClass [

	godotClass := aClass
]

{ #category : #accessing }
GRMockNode >> hasParent: aNode [

	^ self hasParentThat: [:p | p = aNode]
]

{ #category : #accessing }
GRMockNode >> hasParentNamed: aString [

	^ self hasParentThat: [:p | p name = aString]
]

{ #category : #accessing }
GRMockNode >> hasParentThat: aBlock [

	self parentsDo: [:p | (aBlock value: p) ifTrue: [^ true]].
	^ false
]

{ #category : #internal }
GRMockNode >> initialize [

	super initialize.
	
	children := OrderedCollection new.
	properties := Dictionary new
]

{ #category : #internal }
GRMockNode >> insertChild: aChild before: aSibling [

	(children includes: aChild) ifTrue: [children remove: aChild].
	children add: aChild before: aSibling.
	aChild parent: self
]

{ #category : #accessing }
GRMockNode >> name [

	^ name
]

{ #category : #internal }
GRMockNode >> name: aString [

	name := aString asString
]

{ #category : #accessing }
GRMockNode >> orParentOfType: aSymbol [

	self godotClass = aSymbol ifTrue: [^ self].
	^ self parent orParentOfType: aSymbol
]

{ #category : #accessing }
GRMockNode >> parent [

	^ parent
]

{ #category : #internal }
GRMockNode >> parent: aNode [

	parent := aNode
]

{ #category : #accessing }
GRMockNode >> parentOfType: aSymbol [

	^ self parent orParentOfType: aSymbol
]

{ #category : #accessing }
GRMockNode >> parentsDo: aBlock [

	self parent ifNotNil: [:p |
		aBlock value: p.
		p parentsDo: aBlock]
]

{ #category : #accessing }
GRMockNode >> path [

	| current out |
	current := self.
	out := ''.
	[current parent] whileNotNil: [
		out := '/', current name, out.
		current := current parent].
	^ out
]

{ #category : #printing }
GRMockNode >> printOn: aStream [

	aStream nextPutAll: (self godotClass ifNil: ['[root]']).
	aStream nextPut: $(.
	aStream nextPutAll: self name asString.
	aStream nextPut: $)
]

{ #category : #accessing }
GRMockNode >> properties [

	^ properties
]

{ #category : #internal }
GRMockNode >> properties: aDictionary [

	properties := aDictionary
]

{ #category : #utilities }
GRMockNode >> setGlobalTransform: aMatrix [

	^ self subscribe: #'global_transform' set: aMatrix
]

{ #category : #updates }
GRMockNode >> signal: aSymbol [

	^ self signal: aSymbol with: {}
]

{ #category : #updates }
GRMockNode >> signal: aSymbol with: aCollection [

	^ {properties at: aSymbol}, aCollection
]

{ #category : #updates }
GRMockNode >> subscribe: aSymbol set: anObject [

	^ {properties at: 'sqsubscribe_', aSymbol. anObject}
]

{ #category : #updates }
GRMockNode >> subscribeCall: aSymbol index: aNumber with: anObject [

	^ {(properties at: 'sqsubcall_', aSymbol, '_', aNumber) first. anObject}
]

{ #category : #internal }
GRMockNode >> tick: aReact [

	^ self tick: aReact updates: {}
]

{ #category : #internal }
GRMockNode >> tick: aReact updates: aCollection [

	| allUpdates |
	allUpdates := {OrderedCollection new. OrderedCollection new}.
	aReact hostConfig tick: aCollection updatesDo: [:updates |
		allUpdates first addAll: updates first.
		allUpdates second addAll: updates second.
		
		self applyUpdates: updates.
		
		aReact hostConfig waitingRefs
			with: (updates second collect: [:path | GRObjectId new objectId: path])
			do: [:ref :node | ref set: node]].
	^ allUpdates
]

{ #category : #utilities }
GRMockNode >> toggleAX: aBoolean [

	self assert: godotClass = #ARVRController.
	^ self
		signal: (aBoolean ifTrue: [#'button_pressed'] ifFalse: [#'button_release'])
		with: {GDGlobalConstants joyOculusAx}
]

{ #category : #utilities }
GRMockNode >> toggleBY: aBoolean [

	self assert: godotClass = #ARVRController.
	^ self
		signal: (aBoolean ifTrue: [#'button_pressed'] ifFalse: [#'button_release'])
		with: {GDGlobalConstants joyOculusBy}
]

{ #category : #utilities }
GRMockNode >> toggleGrip: aBoolean [

	self assert: godotClass = #ARVRController.
	^ self
		signal: (aBoolean ifTrue: [#'button_pressed'] ifFalse: [#'button_release'])
		with: {GDGlobalConstants joyVrGrip}
]

{ #category : #utilities }
GRMockNode >> toggleTrigger: aBoolean [

	self assert: godotClass = #ARVRController.
	^ self
		signal: (aBoolean ifTrue: [#'button_pressed'] ifFalse: [#'button_release'])
		with: {GDGlobalConstants joyVrTrigger}
]

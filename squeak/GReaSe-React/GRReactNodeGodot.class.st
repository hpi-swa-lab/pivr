Class {
	#name : #GRReactNodeGodot,
	#superclass : #CMFReactNode,
	#instVars : [
		'godotClass',
		'children',
		'key',
		'godotId',
		'isResource',
		'properties',
		'ref'
	],
	#category : #'GReaSe-React'
}

{ #category : #'as yet unclassified' }
GRReactNodeGodot class >> for: aSymbol [

	^ self new godotClass: aSymbol
]

{ #category : #testing }
GRReactNodeGodot >> assertNoRefOnResource [

	" currently not the case "
	"self
		assert: (isResource not or: [ref isNil])
		description: 'Currently, all resources are shared. It is thus not save to reference a particular resource. Please report your use case.'"
]

{ #category : #accessing }
GRReactNodeGodot >> call: aMethodString arguments: aCollection [

	self assert: (aCollection isCollection and: [aCollection isString not]).
	properties at: 'sqcall_', aMethodString put: aCollection
]

{ #category : #accessing }
GRReactNodeGodot >> children [

	^ children
]

{ #category : #accessing }
GRReactNodeGodot >> children: aCollection [

	children := aCollection
]

{ #category : #rendering }
GRReactNodeGodot >> computeChildrenAndUpdate: aFiber for: aState caughtError: anErrorOrNil [

	aFiber output ifNil: [aFiber output: (aState hostConfig create: self)].
	aState reifyCodeLocation: self with: aFiber output.
	
	^ (Array streamContents: [:stream | properties do: [:value | value isGodotNode ifTrue: [stream nextPut: value]]]), (self children ifNotNil: [:c | c isCollection ifTrue: [c] ifFalse: [{c}]] ifNil: [#()])
]

{ #category : #converting }
GRReactNodeGodot >> createInfoFor: aReact [

	^ {self isResource. self godotId. self godotClass. self propertiesToSetFor: aReact. nil}
]

{ #category : #accessing }
GRReactNodeGodot >> doesNotUnderstand: aMessage [

	| key |
	key := aMessage selector.
	(key precedence = 3 and: [(key indexOf: $:) = key size]) ifTrue: [ | value prop |
		prop := key allButLast asSymbol.
		value := aMessage arguments first.
		value isGodotNode ifTrue: [
			value isResource: true.
			value godotId: prop].
		properties at: prop put: value.
		^ self].
	^ super doesNotUnderstand: aMessage
]

{ #category : #accessing }
GRReactNodeGodot >> godotClass [

	^ godotClass
]

{ #category : #accessing }
GRReactNodeGodot >> godotClass: aClassNameSymbol [

	godotClass := aClassNameSymbol
]

{ #category : #accessing }
GRReactNodeGodot >> godotId [

	^ godotId ifNil: [godotId := GRReact nextGodotId asString]
]

{ #category : #accessing }
GRReactNodeGodot >> godotId: anObject [

	godotId := anObject
]

{ #category : #testing }
GRReactNodeGodot >> hasGodotId [

	^ godotId notNil
]

{ #category : #accessing }
GRReactNodeGodot >> hasKey [

	^ key notNil
]

{ #category : #'initialize-release' }
GRReactNodeGodot >> initialize [

	super initialize.
	isResource := false.
	properties := Dictionary new.
	
	GRReact enableCodeMapping ifTrue: [CMFCurrentReact value reportCodeLocation: thisContext sender sender for: self]
]

{ #category : #testing }
GRReactNodeGodot >> isGodotNode [

	^ true
]

{ #category : #testing }
GRReactNodeGodot >> isHostComponent [

	^ true
]

{ #category : #accessing }
GRReactNodeGodot >> isResource [

	^ isResource
]

{ #category : #accessing }
GRReactNodeGodot >> isResource: aBoolean [

	isResource := aBoolean.
	self assertNoRefOnResource
]

{ #category : #testing }
GRReactNodeGodot >> isValidInsertSibling [

	^ self isResource not
]

{ #category : #accessing }
GRReactNodeGodot >> key [

	^ key
]

{ #category : #accessing }
GRReactNodeGodot >> key: anObject [

	key := anObject asString
]

{ #category : #accessing }
GRReactNodeGodot >> meta: aSymbol set: anObject [

	properties at: 'sqmeta_', aSymbol put: anObject
]

{ #category : #'as yet unclassified' }
GRReactNodeGodot >> name: aString [

	godotId := aString
]

{ #category : #printing }
GRReactNodeGodot >> printOn: aStream [

	aStream nextPut: $<.
	aStream nextPutAll: self godotClass.
	aStream nextPut: $ .
	aStream nextPut: $/.
	aStream nextPut: $>
]

{ #category : #accessing }
GRReactNodeGodot >> properties [

	^ properties
]

{ #category : #converting }
GRReactNodeGodot >> propertiesToSetFor: aReact [

	| out |
	out := properties copyEmpty.
	properties associationsDo: [:each | each value isGodotNode ifFalse: [self serializePropValue: each value for: aReact do: [:serialized | out add: each key -> serialized]]].
	^ out
]

{ #category : #'as yet unclassified' }
GRReactNodeGodot >> props [

	^ properties
]

{ #category : #converting }
GRReactNodeGodot >> putVariantOn: aStream [

	^ self shouldNotImplement
]

{ #category : #accessing }
GRReactNodeGodot >> ref [

	^ ref
]

{ #category : #accessing }
GRReactNodeGodot >> ref: aRef [

	ref := aRef.
	self assertNoRefOnResource
]

{ #category : #rendering }
GRReactNodeGodot >> render: react properties: aDictionary renderInfo: renderInfo [

	aDictionary keysAndValuesDo: [:key :value |
		value isGodotNode ifTrue: [ | newNode |
			newNode := react renderNode: value forceReRender: false.
			aDictionary at: key put: newNode]].
	^ aDictionary
]

{ #category : #rendering }
GRReactNodeGodot >> render: react renderInfo: renderInfo userCodeResult: anObject [

	| node |
	node := self.
	renderInfo reusingOldNodes
		ifTrue: [ | oldProps |
			node := renderInfo oldNode.
			godotId := renderInfo oldNode godotId.
			self render: react properties: self properties renderInfo: renderInfo.
			
			oldProps := renderInfo oldNode properties.
			"prop that was in oldProps but is not in newProps"
			self flag: #todo.
			self properties
				ifNil: [oldProps ifNotNil: [oldProps keysDo: [:key | Transcript showln: {#updateRemove. key}]]]
				ifNotNil: [
					self properties keysAndValuesDo: [:key :newValue |
						(newValue isGodotNode not and: [oldProps notNil and: [((oldProps at: key ifAbsent: nil) grEqual: newValue) not]]) ifTrue: [
							self assert: renderInfo treeEntry node hasGodotId.
							self
								serializePropValue: newValue
								for: react
								do: [:serialized | react addUpdate: {#update. renderInfo treeEntry godotPath. key. serialized}]]]]]
		ifFalse: [self render: react properties: self properties renderInfo: renderInfo].
	children ifNotNil: [react renderNodes: children].
	ref ifNotNil: [ref value: react elementTree currentParentEntry].
	
	^ node
]

{ #category : #converting }
GRReactNodeGodot >> serializePropValue: anObject for: aReact do: aBlock [

	anObject isBlock ifTrue: [^ aBlock value: (aReact registerCallback: anObject)].
	anObject class == GRBlockReplace ifTrue: [^ aReact replaceCallback: anObject id with: anObject block].
	anObject class == GRBlockWithArguments ifTrue: [^ aBlock value: {aReact registerCallback: anObject block. anObject arguments}].
	^ aBlock value: anObject
]

{ #category : #accessing }
GRReactNodeGodot >> subscribeCall: aMethodString with: aCollection do: aCallbackClosure [

	| id |
	"append an index to the id. unlike properties, subscribing multiple times make sense if it's different arguments each time"
	id := 'sqsubcall_', aMethodString.
	id := id, '_', (properties keys count: [:key | key beginsWith: id]).
	properties
		at: id
		put: (GRBlockWithArguments new block: aCallbackClosure arguments: aCollection)
]

{ #category : #accessing }
GRReactNodeGodot >> subscribeTo: aPropertyNameString do: aCallbackClosure [

	aCallbackClosure ifNotNil: [properties at: 'sqsubscribe_', aPropertyNameString put: aCallbackClosure]
]

{ #category : #accessing }
GRReactNodeGodot >> type [

	^ {#godot. self godotClass}
]

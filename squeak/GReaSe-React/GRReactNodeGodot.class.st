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

{ #category : #accessing }
GRReactNodeGodot >> children [

	^ children
]

{ #category : #accessing }
GRReactNodeGodot >> children: aCollection [

	children := aCollection
]

{ #category : #converting }
GRReactNodeGodot >> createInfoFor: aReact [

	^ {self isResource. self godotId. self godotClass. self propertiesToSetFor: aReact}
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
	properties := Dictionary new
]

{ #category : #testing }
GRReactNodeGodot >> isGodotNode [

	^ true
]

{ #category : #accessing }
GRReactNodeGodot >> isResource [

	^ isResource
]

{ #category : #accessing }
GRReactNodeGodot >> isResource: aBoolean [

	isResource := aBoolean
]

{ #category : #accessing }
GRReactNodeGodot >> key [

	^ key
]

{ #category : #accessing }
GRReactNodeGodot >> key: anObject [

	key := anObject.
	godotId := key
]

{ #category : #printing }
GRReactNodeGodot >> printOn: aStream [

	aStream nextPut: $<.
	aStream nextPutAll: godotClass.
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
	properties associationsDo: [:each | each value isGodotNode ifFalse: [out add: each key -> (self serializePropValue: each value for: aReact)]].
	^ out
]

{ #category : #accessing }
GRReactNodeGodot >> ref [

	^ ref
]

{ #category : #accessing }
GRReactNodeGodot >> ref: aRef [

	ref := aRef
]

{ #category : #rendering }
GRReactNodeGodot >> render: react properties: aDictionary renderInfo: renderInfo [

	aDictionary keysAndValuesDo: [:key :value |
		value isGodotNode ifTrue: [ | newNode |
			newNode := react renderNode: value forceReRender: false.
			(renderInfo oldNode notNil and: [newNode godotId = ((renderInfo oldNode properties at: key ifAbsent: nil) ifNotNil: [:o | o godotId])]) ifFalse: [
				SBToggledCode
					comment: ''
					active: 0
					do: {[react addUpdate: {#update. renderInfo treeEntry godotPath. key. newNode}]}].
			aDictionary at: key put: newNode].
		SBToggledCode comment: '' active: 0 do: {
			[
				value isBlock ifTrue: [aDictionary at: key put: (react registerCallback: value)].
				(value isKindOf: GRBlockWithArguments) ifTrue: [aDictionary at: key put: {react registerCallback: value block. value arguments}]]}].
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
							react addUpdate: {#update. renderInfo treeEntry godotPath. key. self serializePropValue: newValue for: react}]]]]
		ifFalse: [self render: react properties: self properties renderInfo: renderInfo].
	children ifNotNil: [react renderNodes: children].
	ref ifNotNil: [
		ref isBlock
			ifTrue: [ref value: react elementTree currentParentEntry]
			ifFalse: [react addRef: ref for: renderInfo treeEntry godotPath]].
	
	^ node
]

{ #category : #converting }
GRReactNodeGodot >> serializePropValue: anObject for: aReact [

	anObject isBlock ifTrue: [^ aReact registerCallback: anObject].
	(anObject isKindOf: GRBlockWithArguments) ifTrue: [^ {aReact registerCallback: anObject block. anObject arguments}].
	^ anObject
]

{ #category : #accessing }
GRReactNodeGodot >> subscribeCall: aMethodString with: aCollection do: aCallbackClosure [

	| id |
	"append an index to the id. unlike properties, subscribing multiple times make sense if it's different arguments each time"
	id := 'call_', aMethodString.
	id := id, '_', (properties keys count: [:key | key beginsWith: id]).
	properties
		at: id
		put: (GRBlockWithArguments new block: aCallbackClosure arguments: aCollection)
]

{ #category : #accessing }
GRReactNodeGodot >> subscribeTo: aPropertyNameString do: aCallbackClosure [

	properties at: 'subscribe_', aPropertyNameString put: aCallbackClosure
]

{ #category : #accessing }
GRReactNodeGodot >> type [

	^ {#godot. godotClass}
]
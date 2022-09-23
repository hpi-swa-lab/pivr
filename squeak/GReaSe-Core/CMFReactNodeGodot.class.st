Class {
	#name : #CMFReactNodeGodot,
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
	#category : #'GReaSe-Core'
}

{ #category : #rendering }
CMFReactNodeGodot >> adoptPropsFrom: aNode [

	self assert: godotClass = aNode godotClass.
	properties := aNode properties.
	children := aNode children.
	key := aNode key.
	godotId := aNode godotId.
	isResource := aNode isResource.
	ref := aNode ref
]

{ #category : #accessing }
CMFReactNodeGodot >> children [

	^ children
]

{ #category : #accessing }
CMFReactNodeGodot >> children: aCollection [

	children := aCollection
]

{ #category : #'as yet unclassified' }
CMFReactNodeGodot >> createInfo [

	^ {self isResource. self godotId. self godotClass. self}
]

{ #category : #accessing }
CMFReactNodeGodot >> doesNotUnderstand: aMessage [

	| key |
	key := aMessage selector.
	"(precedence := key precedence) = 1 ifTrue: [^ properties at: key ifAbsent: nil]."
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
CMFReactNodeGodot >> godotClass [

	^ godotClass
]

{ #category : #accessing }
CMFReactNodeGodot >> godotClass: aClassNameSymbol [

	godotClass := aClassNameSymbol
]

{ #category : #accessing }
CMFReactNodeGodot >> godotId [

	^ godotId ifNil: [godotId := CMFReactGodot nextGodotId asString]
]

{ #category : #accessing }
CMFReactNodeGodot >> godotId: anObject [

	godotId := anObject
]

{ #category : #testing }
CMFReactNodeGodot >> hasGodotId [

	^ godotId notNil
]

{ #category : #accessing }
CMFReactNodeGodot >> hasKey [

	^ key notNil
]

{ #category : #'initialize-release' }
CMFReactNodeGodot >> initialize [

	super initialize.
	isResource := false.
	properties := Dictionary new
]

{ #category : #testing }
CMFReactNodeGodot >> isGodotNode [

	^ true
]

{ #category : #accessing }
CMFReactNodeGodot >> isResource [

	^ isResource
]

{ #category : #accessing }
CMFReactNodeGodot >> isResource: aBoolean [

	isResource := aBoolean
]

{ #category : #converting }
CMFReactNodeGodot >> jsonWriteOn: aStream [

	self propertiesToSet jsonWriteOn: aStream
]

{ #category : #accessing }
CMFReactNodeGodot >> key [

	^ key
]

{ #category : #accessing }
CMFReactNodeGodot >> key: anObject [

	key := anObject.
	godotId := key
]

{ #category : #printing }
CMFReactNodeGodot >> printOn: aStream [

	aStream nextPut: $<.
	aStream nextPutAll: godotClass.
	aStream nextPut: $ .
	aStream nextPut: $/.
	aStream nextPut: $>
]

{ #category : #accessing }
CMFReactNodeGodot >> properties [

	^ properties
]

{ #category : #accessing }
CMFReactNodeGodot >> propertiesToSet [

	^ properties select: [:val | val isGodotNode not]
]

{ #category : #converting }
CMFReactNodeGodot >> putVariantOn: aStream [

	self propertiesToSet putVariantOn: aStream
]

{ #category : #accessing }
CMFReactNodeGodot >> ref [

	^ ref
]

{ #category : #accessing }
CMFReactNodeGodot >> ref: aRef [

	ref := aRef
]

{ #category : #rendering }
CMFReactNodeGodot >> render: react properties: aDictionary renderInfo: renderInfo [

	aDictionary keysAndValuesDo: [:key :value |
		value isGodotNode ifTrue: [ | newNode |
			newNode := react renderNode: value forceReRender: false.
			(renderInfo oldNode notNil and: [newNode godotId = ((renderInfo oldNode properties at: key ifAbsent: nil) ifNotNil: [:o | o godotId])]) ifFalse: [react addUpdate: {#update. renderInfo treeEntry godotPath. key. newNode}].
			aDictionary at: key put: newNode].
		value isBlock ifTrue: [aDictionary at: key put: (react registerCallback: value)]].
	^ aDictionary
]

{ #category : #rendering }
CMFReactNodeGodot >> render: react renderInfo: renderInfo userCodeResult: anObject [

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
					self propertiesToSet keysAndValuesDo: [:key :newValue |
						(oldProps notNil and: [(oldProps at: key ifAbsent: nil) = newValue]) ifFalse: [
							self assert: renderInfo treeEntry node hasGodotId.
							react addUpdate: {#update. renderInfo treeEntry godotPath. key. newValue}]]]]
		ifFalse: [self render: react properties: self properties renderInfo: renderInfo].
	children ifNotNil: [react renderNodes: children].
	ref ifNotNil: [
		ref isBlock
			ifTrue: [ref value: react elementTree currentParentEntry]
			ifFalse: [react addRef: ref for: renderInfo treeEntry godotPath]].
	
	^ node
]

{ #category : #accessing }
CMFReactNodeGodot >> subscribeTo: aPropertyNameString do: aCallbackClosure [

	properties at: 'subscribe_', aPropertyNameString put: aCallbackClosure
]

{ #category : #accessing }
CMFReactNodeGodot >> type [

	^ {#godot. godotClass}
]

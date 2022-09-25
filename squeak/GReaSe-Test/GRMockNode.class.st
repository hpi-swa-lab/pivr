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

{ #category : #'as yet unclassified' }
GRMockNode >> addChild: aNode [

	self assert: aNode parent isNil.
	children add: aNode.
	aNode parent: self
]

{ #category : #'as yet unclassified' }
GRMockNode >> allNodesDo: aBlock [

	aBlock value: self.
	self children do: [:child | child allNodesDo: aBlock]
]

{ #category : #'as yet unclassified' }
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
		[#update] -> [
			(self getNodeForPath: anUpdate second) properties
				at: anUpdate third
				put: anUpdate fourth].
		[#delete] -> [(self getNodeForPath: anUpdate second) delete]}
]

{ #category : #'as yet unclassified' }
GRMockNode >> applyUpdates: aCollection [

	aCollection first do: [:update | self applyUpdate: update]
]

{ #category : #'as yet unclassified' }
GRMockNode >> children [

	^ children
]

{ #category : #'as yet unclassified' }
GRMockNode >> delete [

	self parent children remove: self
]

{ #category : #'as yet unclassified' }
GRMockNode >> firstNodeOfType: aSymbol [

	^ self firstNodeThat: [:node | node godotClass = aSymbol]
]

{ #category : #'as yet unclassified' }
GRMockNode >> firstNodeThat: aBlock [

	self allNodesDo: [:node | (aBlock value: node) ifTrue: [^ node]].
	self error: 'no node found'
]

{ #category : #'as yet unclassified' }
GRMockNode >> getNodeForPath: aPath [

	| current |
	current := self.
	aPath ifEmpty: [^ self].
	(aPath allButFirst splitBy: '/') do: [:part | current := current children detect: [:child | child name = part]].
	^ current
]

{ #category : #'as yet unclassified' }
GRMockNode >> godotClass [

	^ godotClass
]

{ #category : #'as yet unclassified' }
GRMockNode >> godotClass: aClass [

	godotClass := aClass
]

{ #category : #'as yet unclassified' }
GRMockNode >> initialize [

	super initialize.
	
	children := OrderedCollection new.
	properties := Dictionary new
]

{ #category : #'as yet unclassified' }
GRMockNode >> name [

	^ name
]

{ #category : #'as yet unclassified' }
GRMockNode >> name: aString [

	name := aString asString
]

{ #category : #'as yet unclassified' }
GRMockNode >> parent [

	^ parent
]

{ #category : #'as yet unclassified' }
GRMockNode >> parent: aNode [

	parent := aNode
]

{ #category : #'as yet unclassified' }
GRMockNode >> printOn: aStream [

	aStream nextPutAll: self className.
	aStream nextPut: $(.
	aStream nextPutAll: self name asString.
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
GRMockNode >> properties [

	^ properties
]

{ #category : #'as yet unclassified' }
GRMockNode >> properties: aDictionary [

	properties := aDictionary
]

{ #category : #'as yet unclassified' }
GRMockNode >> tick: aReact [

	^ self tick: aReact updates: {}
]

{ #category : #'as yet unclassified' }
GRMockNode >> tick: aReact updates: aCollection [

	| updates |
	updates := aReact tick: aCollection.
	self applyUpdates: updates.
	^ updates
]

{ #category : #'as yet unclassified' }
GRMockNode >> trigger: aSymbol [

	^ self trigger: aSymbol with: {}
]

{ #category : #'as yet unclassified' }
GRMockNode >> trigger: aSymbol with: aCollection [

	^ {properties at: aSymbol}, aCollection
]

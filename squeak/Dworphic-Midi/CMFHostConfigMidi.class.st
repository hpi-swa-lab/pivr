Class {
	#name : #CMFHostConfigMidi,
	#superclass : #CMFHostConfig,
	#category : #'Dworphic-Midi'
}

{ #category : #reconciliation }
CMFHostConfigMidi >> appendChild: aHostNode in: aParentHostNode fiber: aFiber [

	(aParentHostNode children includes: aHostNode) ifTrue: [aParentHostNode children remove: aHostNode].
	aParentHostNode addChild: aHostNode
]

{ #category : #reconciliation }
CMFHostConfigMidi >> create: aNode [

	| node |
	node := aNode tag new.
	aNode properties keysAndValuesDo: [:prop :value | node perform: prop asSimpleSetter with: value].
	^ node
]

{ #category : #reconciliation }
CMFHostConfigMidi >> prepareUpdateFrom: aNode to: anotherNode for: aHostNode [

	^ self diffPropsFrom: aNode to: anotherNode
]

{ #category : #reconciliation }
CMFHostConfigMidi >> removeChild: aHostNode in: aParentHostNode [

	aParentHostNode removeChild: aHostNode
]

{ #category : #reconciliation }
CMFHostConfigMidi >> update: aHostNode new: aNewNode hostUpdate: aHostUpdate [

	aHostUpdate keysAndValuesDo: [:key :value | aHostNode perform: key asSimpleSetter with: value]
]

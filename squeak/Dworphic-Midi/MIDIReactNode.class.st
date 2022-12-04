Class {
	#name : #MIDIReactNode,
	#superclass : #CMFReactNode,
	#instVars : [
		'children',
		'key',
		'properties',
		'tag'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDIReactNode >> children [

	^ children
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> children: aCollection [

	children := aCollection
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> computeChildrenAndUpdate: aFiber for: aState caughtError: anErrorOrNil [

	aFiber output ifNil: [aFiber output: (aState hostConfig create: self)].
	^ self children
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> doesNotUnderstand: aMessage [

	| key |
	key := aMessage selector.
	(key precedence = 3 and: [(key indexOf: $:) = key size]) ifTrue: [ | value prop |
		prop := key allButLast asSymbol.
		value := aMessage arguments first.
		properties at: prop put: value.
		^ self].
	(key precedence = 1 and: [properties includesKey: key]) ifTrue: [^ properties at: key].
	^ super doesNotUnderstand: aMessage
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> hasKey [

	^ key notNil
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> initialize [

	super initialize.
	properties := Dictionary new
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> isHostComponent [

	^ true
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> key [

	^ key
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> key: anObject [

	key := anObject
]

{ #category : #printing }
MIDIReactNode >> printOn: aStream [

	aStream nextPut: $<.
	aStream print: tag.
	aStream nextPutAll: ' />'
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> properties [

	^ properties
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> props [

	^ properties
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> tag [

	^ tag
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> tag: anObject [

	tag := anObject
]

{ #category : #'as yet unclassified' }
MIDIReactNode >> type [

	^ {tag}
]

Class {
	#name : #GDMethodSpec,
	#superclass : #Object,
	#instVars : [
		'name',
		'arguments',
		'className',
		'methodCategory',
		'returnType'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #'instance creation' }
GDMethodSpec class >> newNamed: name arguments: argumentSpecs category: category className: className [

	^ self new
		name: name;
		arguments: argumentSpecs;
		methodCategory: category;
		className: className
]

{ #category : #'as yet unclassified' }
GDMethodSpec class >> squeakifyMethodName: aString [

	| parts |
	parts := aString subStrings: '_'.
	^ parts first, (parts allButFirst collect: #capitalized) join
]

{ #category : #accessing }
GDMethodSpec >> arguments [

	^ arguments
]

{ #category : #accessing }
GDMethodSpec >> arguments: anArgSpecSequence [

	arguments := anArgSpecSequence
]

{ #category : #accessing }
GDMethodSpec >> className [

	^ className
]

{ #category : #accessing }
GDMethodSpec >> className: aString [

	className := aString
]

{ #category : #generating }
GDMethodSpec >> generate [

	| method selector source |
	source := self source.
	selector := self methodClass
		compileSilently: self source
		classified: methodCategory.
	method := self methodClass compiledMethodAt: selector.
	method becomeForward: (method copyWithSourceCode: self source)
]

{ #category : #accessing }
GDMethodSpec >> isClassMethod [

	^ false
]

{ #category : #accessing }
GDMethodSpec >> methodCategory [

	^ methodCategory
]

{ #category : #accessing }
GDMethodSpec >> methodCategory: aString [

	methodCategory := aString
]

{ #category : #accessing }
GDMethodSpec >> methodClass [

	| methodClass |
	methodClass := Smalltalk classNamed: className.
	^ self isClassMethod
		ifTrue: [methodClass class]
		ifFalse: [methodClass]
]

{ #category : #accessing }
GDMethodSpec >> name [

	^ name
]

{ #category : #accessing }
GDMethodSpec >> name: aString [

	name := aString
]

{ #category : #'as yet unclassified' }
GDMethodSpec >> returnType [

	^ returnType
]

{ #category : #'as yet unclassified' }
GDMethodSpec >> returnType: aSymbol [

	returnType := aSymbol
]

{ #category : #generating }
GDMethodSpec >> source [

	self subclassResponsibility
]

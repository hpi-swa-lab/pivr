Class {
	#name : #GDClassSpec,
	#superclass : #Object,
	#instVars : [
		'parentName',
		'name',
		'category',
		'isSingleton',
		'singletonName'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #'instance creation' }
GDClassSpec class >> fromApiJsonObject: aJsonObject [

	^ self new
		name: (GDApiObjectsGenerator squeakClassName: ((aJsonObject name first = $_ and: [aJsonObject singleton_name notEmpty])
			ifTrue: [aJsonObject singleton_name]
			ifFalse: [aJsonObject name])) asSymbol;
		parentName: (aJsonObject base_class
			ifEmpty: [self rootClassName]
			ifNotEmpty: [:name | GDApiObjectsGenerator squeakClassName: name]);
		category: (GDApiObjectsGenerator fullCategoryName: 'Uncategorized');
		isSingleton: aJsonObject singleton;
		singletonName: aJsonObject singleton_name
]

{ #category : #constants }
GDClassSpec class >> rootClassName [

	^ 'GDBaseObject'
]

{ #category : #accessing }
GDClassSpec >> category [

	^ category
]

{ #category : #accessing }
GDClassSpec >> category: aString [

	category := aString
]

{ #category : #generating }
GDClassSpec >> generate [

	| class |
	class := self parentClass
		subclass: name
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: category.
	
	class
		compile: ('godotClass

	^ {1}' format: {(name allButFirst: GDApiObjectsGenerator classPrefix size) asSymbol storeString})
		classified: 'accessing'.
	class class
		compile: ('instance

	^ self new objectId: {1}' format: {self singletonName storeString})
		classified: 'accessing'.
	
	^ class
]

{ #category : #initialization }
GDClassSpec >> initialize [

	self isSingleton: false
]

{ #category : #accessing }
GDClassSpec >> isSingleton [

	^ isSingleton
]

{ #category : #accessing }
GDClassSpec >> isSingleton: aBoolean [

	isSingleton := aBoolean
]

{ #category : #accessing }
GDClassSpec >> name [

	^ name
]

{ #category : #accessing }
GDClassSpec >> name: aSymbol [

	name := aSymbol
]

{ #category : #generating }
GDClassSpec >> parentClass [

	^ (Smalltalk classNamed: parentName)
		ifNil: [self error: ('Parent class {1} for {2} does not exist' format: {parentName. name})]
]

{ #category : #accessing }
GDClassSpec >> parentName [

	^ parentName
]

{ #category : #accessing }
GDClassSpec >> parentName: aString [

	parentName := aString
]

{ #category : #accessing }
GDClassSpec >> singletonName [

	^ singletonName
]

{ #category : #accessing }
GDClassSpec >> singletonName: aString [

	singletonName := aString
]

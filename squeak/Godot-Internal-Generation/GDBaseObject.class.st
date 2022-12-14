Class {
	#name : #GDBaseObject,
	#superclass : #GRReactNodeGodot,
	#instVars : [
		'objectId'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #'as yet unclassified' }
GDBaseObject class >> externalNew [

	| wrapper |
	wrapper := self basicNew.
	wrapper objectId: (GRReactCurrentSession value createInstanceOf: wrapper godotClass) objectId.
	^ wrapper
]

{ #category : #'as yet unclassified' }
GDBaseObject class >> externalNewDuring: aBlock [

	| instance |
	instance := self externalNew.
	^ [aBlock value: instance] ensure: [instance unreference]
]

{ #category : #'as yet unclassified' }
GDBaseObject class >> toolIcon [

	^ #godot
]

{ #category : #'as yet unclassified' }
GDBaseObject >> = anObject [

	objectId ifNil: [^ super = anObject].
	^ (anObject respondsTo: #objectId) and: [anObject objectId = self objectId]
]

{ #category : #'as yet unclassified' }
GDBaseObject >> callOnVariant: aString with: aCollection return: aClassNameSymbol [

	self assert: objectId notNil.
	^ (GRReactCurrentSession value
		callOn: self
		method: aString
		arguments: aCollection) grAsClass: aClassNameSymbol
]

{ #category : #'as yet unclassified' }
GDBaseObject >> doesNotUnderstand: aMessage [

	| exception resumeValue |
	"Handle the fact that there was an attempt to send the given
	  message to the receiver but the receiver does not understand
	  this message (typically sent from the machine when a message
	  is sent to the receiver and no method is defined for that selector).

	 Raise the MessageNotUnderstood signal.  If it is caught, answer
	 the result supplied by the exception handler.  If it is not caught,
	 answer the result of resending the message within a guard for
	 infinite recursion. This allows, for example, the programmer to
	 implement the method and continue."
	"Testing: (3 activeProcess)"
	(exception := MessageNotUnderstood new)
		message: aMessage;
		receiver: self.
	resumeValue := exception signal.
	^ exception reachedDefaultHandler
		ifTrue: [
			"i.e. exception was not caught..."
			[aMessage sentTo: self] on: MessageNotUnderstood do: [:ex |
				(self == ex receiver and: [aMessage hasIdenticalContentsAs: ex message]) ifFalse: [ex pass].
				self error: 'infinite recursion in doesNotUnderstand:']]
		ifFalse: [resumeValue]
]

{ #category : #'as yet unclassified' }
GDBaseObject >> explorerContents [

	true ifTrue: ["for now, we cannot ask Godot from a different thread for info, so we cannot use the more sophisticated display yet"
	^ super explorerContents].
	
	^ self explorerContentsChildren, self explorerContentsSceneTree, super explorerContents, self explorerContentsProperties
]

{ #category : #'as yet unclassified' }
GDBaseObject >> explorerContentsChildren [

	^ (self respondsTo: #getChildren)
		ifTrue: [{ObjectExplorerWrapper with: self getChildren name: 'Children' model: self}]
		ifFalse: [{}]
]

{ #category : #'as yet unclassified' }
GDBaseObject >> explorerContentsGodotProperties [

	^ self getPropertyList collect: [:name | | value |
		value := [self getProperty: name]
			on: Error
			do: [:error | 'Failed to fetch property: ', error].
		ObjectExplorerWrapper with: value name: '#', name model: self]
]

{ #category : #'as yet unclassified' }
GDBaseObject >> explorerContentsProperties [

	"self explorerContentsScriptProperties."
	^ self explorerContentsGodotProperties
]

{ #category : #'as yet unclassified' }
GDBaseObject >> explorerContentsSceneTree [

	^ (self respondsTo: #getTree)
		ifTrue: [{ObjectExplorerWrapper with: self getTree name: 'Scene Tree' model: self}]
		ifFalse: [{}]
]

{ #category : #'as yet unclassified' }
GDBaseObject >> get: aSymbol return: aClassNameSymbol [

	self assert: objectId notNil.
	^ (GRReactCurrentSession value get: aSymbol of: self) grAsClass: aClassNameSymbol
]

{ #category : #'as yet unclassified' }
GDBaseObject >> grAsClass: aSymbol [

	^ (Smalltalk classNamed: aSymbol) basicNew objectId: self objectId
]

{ #category : #'as yet unclassified' }
GDBaseObject >> hash [

	objectId ifNil: [^ super hash].
	^ objectId hash
]

{ #category : #'as yet unclassified' }
GDBaseObject >> isGodotNode [

	^ objectId isNil
]

{ #category : #'as yet unclassified' }
GDBaseObject >> objectId [

	^ objectId
]

{ #category : #'as yet unclassified' }
GDBaseObject >> objectId: anObject [

	objectId := anObject
]

{ #category : #'as yet unclassified' }
GDBaseObject >> putVariantOn: aWriteStream [

	self assert: objectId notNil.
	
	" for singletons, we pass in the string name instead "
	objectId isString ifTrue: [^ objectId putVariantOn: aWriteStream].
	
	aWriteStream nextLittleEndianNumber: 4 put: (17 bitOr: (1 bitShift: 16)).
	aWriteStream nextLittleEndianNumber: 8 put: objectId
]

{ #category : #'as yet unclassified' }
GDBaseObject >> set: aSymbol to: anObject [

	objectId
		ifNil: [
			aSymbol = #name ifTrue: [godotId := anObject].
			anObject isGodotNode ifTrue: [
				anObject isResource: true.
				anObject godotId: aSymbol].
			properties at: aSymbol put: anObject]
		ifNotNil: [GRReactCurrentSession value set: aSymbol of: self to: anObject]
]

{ #category : #'as yet unclassified' }
GDBaseObject >> setAll: aDictionary [

	aDictionary ifNotNil: [aDictionary keysAndValuesDo: [:key :value |
			key = #children ifFalse: [self set: key to: value]]]
]

{ #category : #'as yet unclassified' }
GDBaseObject >> unreference [
	"unreference a godot object created via externalNew"

	GRReactCurrentSession value freeInstance: godotId
]

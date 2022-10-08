Class {
	#name : #GDBaseObject,
	#superclass : #GRReactNodeGodot,
	#instVars : [
		'objectId'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #'as yet unclassified' }
GDBaseObject class >> toolIcon [

	^ #godot
]

{ #category : #'as yet unclassified' }
GDBaseObject >> = anObject [

	objectId ifNil: [^ super = anObject].
	^ self class = anObject class and: [anObject objectId = self objectId]
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

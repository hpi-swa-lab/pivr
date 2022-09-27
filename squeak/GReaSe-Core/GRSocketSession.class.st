Class {
	#name : #GRSocketSession,
	#superclass : #Object,
	#instVars : [
		'react',
		'sessionId',
		'stream',
		'communicationLock',
		'codeChanged'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRSocketSession >> bindRefs: aCollection [

	react waitingRefs with: aCollection do: [:ref :obj | ref set: obj]
]

{ #category : #'as yet unclassified' }
GRSocketSession >> callOn: anObject method: aString arguments: aCollection [

	| response |
	GRSocketListener
		putVariant: {GRSocketListener messageTypeCallFromSqueak. anObject. aString. aCollection}
		on: stream.
	
	response := GRSocketListener readMessageFrom: stream.
	self assert: response first = GRSocketListener messageTypeResponseToCallFromGodot.
	self assert: response second = sessionId.
	^ response third
]

{ #category : #'as yet unclassified' }
GRSocketSession >> close [

	[stream ifNotNil: #close] on: Error do: [:error |]
]

{ #category : #'as yet unclassified' }
GRSocketSession >> codeChanged: event [

	event isDoIt ifTrue: [^ self].
	self synchronousCodeReload ifFalse: [
		codeChanged := true.
		^ self].
	
	(react codeChanged: event) then: [:unused | self communicationLockDuring: [GRSocketListener putVariant: 'code_changed' on: stream]]
]

{ #category : #'as yet unclassified' }
GRSocketSession >> communicationLockDuring: aBlock [

	^ communicationLock critical: aBlock
]

{ #category : #'as yet unclassified' }
GRSocketSession >> createInstanceOf: aString [

	| response |
	GRSocketListener
		putVariant: {GRSocketListener messageTypeCreateInstanceFromSqueak. aString}
		on: stream.
	
	response := GRSocketListener readMessageFrom: stream.
	self assert: response first = GRSocketListener messageTypeCreatedInstanceFromGodot.
	self assert: response second = sessionId.
	^ response third
]

{ #category : #'as yet unclassified' }
GRSocketSession >> freeInstance: anObjectId [

	GRSocketListener
		putVariant: {GRSocketListener messageTypeFreeInstanceFromSqueak. anObjectId}
		on: stream
]

{ #category : #'as yet unclassified' }
GRSocketSession >> get: aString of: anObject [

	| response |
	GRSocketListener
		putVariant: {GRSocketListener messageTypePropertyGetFromSqueak. anObject. aString}
		on: stream.
	
	response := GRSocketListener readMessageFrom: stream.
	self assert: response first = GRSocketListener messageTypeResponseToCallFromGodot.
	self assert: response second = sessionId.
	^ response third
]

{ #category : #communication }
GRSocketSession >> handleMessage: aMessage [

	aMessage first caseOf: {
		[GRSocketListener messageTypeTickFromGodot] -> [
			[
				[
					self tick: aMessage third updatesDo: [:updates |
						self putVariant: {GRSocketListener messageTypeTickUpdateFromSqueak. updates}.
						updates second ifNotEmpty: [ | refsMessage |
							refsMessage := GRSocketListener readMessageFrom: stream.
							self assert: refsMessage first = GRSocketListener messageTypeRefsFromGodot.
							self bindRefs: refsMessage third]]] ensure: [self putVariant: {GRSocketListener messageTypeTickCompletedFromSqueak}]]
				on: ConnectionClosed, SocketPrimitiveFailed
				do: [:error | ^ false]
				on: Error
				do: [:error |
					self spawnHandlerProcess.
					error signal]].
		[GRSocketListener messageTypeInitializeSessionFromGodot] -> [self putVariant: {GRSocketListener messageTypeInitializedSessionFromSqueak. self sessionId. GRObjectId new objectId: 0}].
		[GRSocketListener messageTypeQuitFromGodot] -> [
			SBToggledCode
				comment: ''
				active: 0
				do: {[ | sessions |sessions removeKey: aMessage second]}.
			self close.
			^ false].
		[GRSocketListener messageTypeResponseToCallFromGodot] -> [self error: 'message sent on wrong thread? response arrived in listener loop']}.
	^ true
]

{ #category : #'as yet unclassified' }
GRSocketSession >> initialize [

	super initialize.
	
	codeChanged := false.
	communicationLock := Mutex new
]

{ #category : #'as yet unclassified' }
GRSocketSession >> putVariant: anObject [

	GRSocketListener putVariant: anObject on: stream
]

{ #category : #'as yet unclassified' }
GRSocketSession >> reactComponent: aComponentClass [

	react := GRReact new
		session: self;
		init: aComponentClass new
]

{ #category : #communication }
GRSocketSession >> receiveMessage [

	| message |
	message := [GRSocketListener readMessageFrom: stream]
		on: ConnectionClosed, SocketPrimitiveFailed
		do: [^ false].
	^ self communicationLockDuring: [self handleMessage: message]
]

{ #category : #'as yet unclassified' }
GRSocketSession >> sessionId [

	^ sessionId ifNil: [sessionId := GRReact nextGodotId]
]

{ #category : #'as yet unclassified' }
GRSocketSession >> set: aString of: anObject to: aValueObject [

	| response |
	GRSocketListener
		putVariant: {GRSocketListener messageTypePropertySetFromSqueak. anObject. aString. aValueObject}
		on: stream.
	
	response := GRSocketListener readMessageFrom: stream.
	self assert: response first = GRSocketListener messageTypeResponseToCallFromGodot.
	self assert: response second = sessionId.
	^ response third
]

{ #category : #'as yet unclassified' }
GRSocketSession >> socketStream: aStream [

	stream := aStream
]

{ #category : #communication }
GRSocketSession >> spawnHandlerProcess [

	[[stream atEnd ifFalse: [self receiveMessage] ifTrue: [true]] whileTrue]
		forkAt: Processor highIOPriority
		named: '[Godot Session Connection]'
]

{ #category : #'as yet unclassified' }
GRSocketSession >> synchronousCodeReload [

	^ false
]

{ #category : #'as yet unclassified' }
GRSocketSession >> tick: aCollection updatesDo: aBlock [

	codeChanged ifTrue: [
		react onCodeChanged.
		codeChanged := false].
	^ react tick: aCollection updatesDo: aBlock
]

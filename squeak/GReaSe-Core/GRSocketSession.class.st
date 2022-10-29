Class {
	#name : #GRSocketSession,
	#superclass : #Object,
	#instVars : [
		'react',
		'sessionId',
		'stream',
		'communicationLock',
		'codeChanged',
		'renderingErrored'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRSocketSession >> bindRefs: aCollection [

	react hostConfig waitingRefs with: aCollection do: [:ref :obj | ref set: obj]
]

{ #category : #'as yet unclassified' }
GRSocketSession >> callOn: anObject method: aString [

	^ self callOn: anObject method: aString arguments: #()
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

	react hostConfig onShutdown.
	[stream ifNotNil: #close] on: Error do: [:error | ]
]

{ #category : #'as yet unclassified' }
GRSocketSession >> codeChanged: event [

	event isDoIt ifTrue: [^ self].
	renderingErrored := false.
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

{ #category : #'as yet unclassified' }
GRSocketSession >> handleError: anError [
	"spawn a new handler loop process so that we can debug the error'ed one"

	self spawnHandlerProcess.
	ToolSet debugException: anError
]

{ #category : #communication }
GRSocketSession >> handleMessage: aMessage [

	^ aMessage first caseOf: {
		[GRSocketListener messageTypeTickFromGodot] -> [self handleRenderMessage: aMessage].
		[GRSocketListener messageTypeInitializeSessionFromGodot] -> [
			self putVariant: {GRSocketListener messageTypeInitializedSessionFromSqueak. self sessionId. GRObjectId new objectId: 0}.
			true].
		[GRSocketListener messageTypeQuitFromGodot] -> [
			self close.
			false]}
]

{ #category : #'as yet unclassified' }
GRSocketSession >> handleRenderMessage: aMessage [

	renderingErrored ifTrue: [
		Transcript showln: 'Ignoring update from Godot until next code change because of error.'.
		self putVariant: {GRSocketListener messageTypeTickCompletedFromSqueak}.
		^ true].
	
	^ [
		GRDebug reportFrameTime: [
			self
				tick: (aMessage third collect: [:update | GRSocketListener readVariantFrom: update readStream])
				updatesDo: [:updates |
					self putVariant: {GRSocketListener messageTypeTickUpdateFromSqueak. updates}.
					self readRefs]].
		self putVariant: {GRSocketListener messageTypeTickCompletedFromSqueak}.
		true]
		on: ConnectionClosed, SocketPrimitiveFailed
		do: [:error | false]
		on: Error, Halt, Warning
		do: [:error |
			self putVariant: {GRSocketListener messageTypeTickCompletedFromSqueak}.
			renderingErrored := true.
			self handleError: error.
			false]
]

{ #category : #'as yet unclassified' }
GRSocketSession >> initialize [

	super initialize.
	
	codeChanged := false.
	communicationLock := Mutex new.
	renderingErrored := false
]

{ #category : #'as yet unclassified' }
GRSocketSession >> putVariant: anObject [

	GRSocketListener putVariant: anObject on: stream
]

{ #category : #'as yet unclassified' }
GRSocketSession >> react: aReact [

	react := aReact
]

{ #category : #'as yet unclassified' }
GRSocketSession >> reactComponent: aComponentClass [

	react := GRReact useFibers
		ifTrue: [
			(Smalltalk at: #CMFReactWithFibers) new
				hostConfig: (CMFHostConfigGodot new session: self);
				renderRoot: aComponentClass new in: {#add. ''. false. ''}]
		ifFalse: [
			GRReact new
				session: self;
				init: aComponentClass new]
]

{ #category : #'as yet unclassified' }
GRSocketSession >> readRefs [

	| refsMessage |
	refsMessage := GRSocketListener readMessageFrom: stream.
	self assert: refsMessage first = GRSocketListener messageTypeRefsFromGodot.
	self bindRefs: refsMessage third
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
	^ react hostConfig tick: aCollection updatesDo: aBlock
]

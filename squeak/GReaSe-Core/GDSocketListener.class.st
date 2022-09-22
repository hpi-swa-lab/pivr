Class {
	#name : #GDSocketListener,
	#superclass : #Object,
	#instVars : [
		'listener',
		'process',
		'sessions',
		'componentClass'
	],
	#classVars : [
		'Current'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GDSocketListener class >> messageTypeCallFromSqueak [

	^ 2
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> messageTypeInitializeSessionFromGodot [

	^ 4
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> messageTypeInitializedSessionFromSqueak [

	^ 5
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> messageTypePropertyGetFromSqueak [

	^ 8
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> messageTypePropertySetFromSqueak [

	^ 7
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> messageTypeQuitFromGodot [

	^ 6
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> messageTypeRefsFromGodot [

	^ 9
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> messageTypeResponseToCallFromGodot [

	^ 3
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> messageTypeTickCompletedFromSqueak [

	^ 1
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> messageTypeTickFromGodot [

	^ 0
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> putVariant: anObject on: aSocketStream [

	| buffer size |
	buffer := ByteArray streamContents: [:stream | anObject putVariantOn: stream].
	size := Array new: 4.
	(WriteStream on: size) nextLittleEndianNumber: 4 put: buffer size.
	aSocketStream nextPutAll: size.
	aSocketStream nextPutAll: buffer.
	aSocketStream flush
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> readMessageFrom: aStream [

	| messageLength |
	messageLength := (aStream next: 4) readStream nextLittleEndianNumber: 4.
	^ self readVariantFrom: (aStream next: messageLength) readStream
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> readVariantFrom: aStream [

	| type is64Bit |
	type := aStream nextLittleEndianNumber: 4.
	is64Bit := (type bitAnd: (1 bitShift: 16)) ~= 0.
	^ (type bitAnd: 255) caseOf: {
		[0] -> [nil].
		[1] -> [(aStream nextLittleEndianNumber: 4) ~= 0].
		[2] -> [aStream nextLittleEndianNumber: (is64Bit ifTrue: [8] ifFalse: [4])].
		[3] -> [
			is64Bit
				ifTrue: [Float fromIEEE64Bit: (aStream nextLittleEndianNumber: 8)]
				ifFalse: [Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4)]].
		[4] -> [ | length pad string |
			length := aStream nextLittleEndianNumber: 4.
			pad := length \\ 4 > 0 ifTrue: [4 - (length \\ 4)] ifFalse: [0].
			string := (aStream next: length) utf8Decoded.
			aStream next: pad.
			string].
		[13] -> [
			self flag: #todo.
			"is the rotation in the right order? translation is correct"
			Matrix4x4 new
				a11: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a12: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a13: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a21: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a22: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a23: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a31: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a32: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a33: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a14: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a24: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a34: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4));
				a44: 1;
				yourself].
		[17] -> [ | objectId |
			self assert: (type bitAnd: (1 bitShift: 16)) ~= 0.
			objectId := aStream nextLittleEndianNumber: 8.
			objectId = 0 ifTrue: [nil] ifFalse: [GDObjectId new objectId: objectId]].
		[18] -> [ | count |
			count := (aStream nextLittleEndianNumber: 4) bitAnd: 2147483647.
			Dictionary newFrom: ((1 to: count) collect: [:index | (self readVariantFrom: aStream) -> (self readVariantFrom: aStream)])].
		[19] -> [ | count |
			count := (aStream nextLittleEndianNumber: 4) bitAnd: 2147483647.
			(1 to: count) collect: [:index | self readVariantFrom: aStream]]}
]

{ #category : #'as yet unclassified' }
GDSocketListener class >> start: aComponentClass [

	| listener |
	Current ifNotNil: [Current destroy].
	
	listener := self new.
	Current := listener.
	listener componentClass: aComponentClass.
	listener spawnListener.
	^ listener
]

{ #category : #accessing }
GDSocketListener >> componentClass [

	^ componentClass
]

{ #category : #accessing }
GDSocketListener >> componentClass: aClass [

	componentClass := aClass
]

{ #category : #communication }
GDSocketListener >> destroy [

	listener destroy.
	process terminate.
	sessions do: #close
]

{ #category : #communication }
GDSocketListener >> handleConnection: aSocket [

	| stream |
	stream := SocketStream on: aSocket.
	stream timeout: 100000.
	stream binary.
	[stream atEnd ifFalse: [(self handleMessage: stream) ifFalse: [^ self]]] repeat
]

{ #category : #'as yet unclassified' }
GDSocketListener >> handleMessage: stream [

	| message |
	message := self class readMessageFrom: stream.
	message first caseOf: {
		[self class messageTypeTickFromGodot] -> [ | updates |
			updates := (sessions at: message second) tick: message third.
			self class putVariant: {self class messageTypeTickCompletedFromSqueak. updates} on: stream].
		[self class messageTypeInitializeSessionFromGodot] -> [ | session |
			session := GDSocketSession new
				reactComponent: self componentClass;
				socketStream: stream.
			sessions at: session sessionId put: session.
			self class
				putVariant: {self class messageTypeInitializedSessionFromSqueak. session sessionId. GDObjectId new objectId: 0}
				on: stream].
		[self class messageTypeQuitFromGodot] -> [
			sessions removeKey: message second.
			stream close.
			^ false].
		[self class messageTypeResponseToCallFromGodot] -> [self error: 'message sent on wrong thread? response arrived in listener loop'].
		[self class messageTypeRefsFromGodot] -> [(sessions at: message second) bindRefs: message third]}.
	^ true
]

{ #category : #'initialize-release' }
GDSocketListener >> initialize [

	sessions := Dictionary new
]

{ #category : #communication }
GDSocketListener >> spawnListener [

	listener := Socket newTCP.
	listener listenOn: 8292 backlogSize: 15.
	listener isWaitingForConnection ifFalse: [^ self error: 'Failed to connect'].
	process := [
		[listener isValid] whileTrue: [
			(listener waitForAcceptFor: 10000000) ifNotNil: [:connection |
				[self handleConnection: (SBWatch report: connection for: 663488349)]
					forkAt: Processor highIOPriority
					named: '[Godot Session Connection]']].
		listener destroy]
		forkAt: Processor lowIOPriority
		named: '[Godot Socket Listener]'
]

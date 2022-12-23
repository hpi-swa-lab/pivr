Class {
	#name : #GRSocketListener,
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
GRSocketListener class >> current [

	^ Current
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeCallFromSqueak [

	^ 2
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeCreateInstanceFromSqueak [

	^ 11
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeCreatedInstanceFromGodot [

	^ 12
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeFreeInstanceFromSqueak [

	^ 13
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeInitializeSessionFromGodot [

	^ 4
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeInitializedSessionFromSqueak [

	^ 5
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeLoadResourceFromSqueak [

	^ 14
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeLoadedResourceFromGodot [

	^ 15
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypePropertyGetFromSqueak [

	^ 8
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypePropertySetFromSqueak [

	^ 7
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeQuitFromGodot [

	^ 6
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeRefsFromGodot [

	^ 9
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeResponseToCallFromGodot [

	^ 3
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeTickCompletedFromSqueak [

	^ 1
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeTickFromGodot [

	^ 0
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> messageTypeTickUpdateFromSqueak [

	^ 10
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> putVariant: anObject on: aSocketStream [

	| buffer size |
	buffer := ByteArray streamContents: [:stream | anObject putVariantOn: stream].
	size := Array new: 4.
	(WriteStream on: size) nextLittleEndianNumber: 4 put: buffer size.
	aSocketStream nextPutAll: size.
	aSocketStream nextPutAll: buffer.
	aSocketStream flush
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> readMessageFrom: aStream [

	| messageLength |
	messageLength := (aStream next: 4) readStream nextLittleEndianNumber: 4.
	^ self readVariantFrom: (aStream next: messageLength) readStream
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> readStringFrom: aStream [

	| length pad string |
	length := aStream nextLittleEndianNumber: 4.
	pad := length \\ 4 > 0 ifTrue: [4 - (length \\ 4)] ifFalse: [0].
	string := (aStream next: length) utf8Decoded.
	aStream next: pad.
	^ string
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> readVariantFrom: aStream [

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
		[4] -> [self readStringFrom: aStream].
		[5] -> [
			Vector2
				x: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4))
				y: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4))].
		[6] -> [
			Rectangle
				origin: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4)) @ (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4))
				corner: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4)) @ (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4))].
		[7] -> [
			Vector3
				x: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4))
				y: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4))
				z: (Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4))].
		[13] -> [
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
		[14] -> [
			Color
				r: (is64Bit
					ifTrue: [Float fromIEEE64Bit: (aStream nextLittleEndianNumber: 8)]
					ifFalse: [Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4)])
				g: (is64Bit
					ifTrue: [Float fromIEEE64Bit: (aStream nextLittleEndianNumber: 8)]
					ifFalse: [Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4)])
				b: (is64Bit
					ifTrue: [Float fromIEEE64Bit: (aStream nextLittleEndianNumber: 8)]
					ifFalse: [Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4)])
				alpha: (is64Bit
					ifTrue: [Float fromIEEE64Bit: (aStream nextLittleEndianNumber: 8)]
					ifFalse: [Float fromIEEE32Bit: (aStream nextLittleEndianNumber: 4)])].
		[15] -> [ | nameCount subnameCount flags isAbsolute |
			nameCount := (aStream nextLittleEndianNumber: 4) bitAnd: 2147483647.
			subnameCount := aStream nextLittleEndianNumber: 4.
			flags := aStream nextLittleEndianNumber: 4.
			(flags bitAnd: 2) ~= 0 ifTrue: [subnameCount := subnameCount + 1].
			isAbsolute := (flags bitAnd: 1) ~= 0.
			String streamContents: [:stream |
				isAbsolute ifTrue: [stream nextPut: $/].
				(1 to: nameCount)
					do: [:i | stream nextPutAll: (self readStringFrom: aStream)]
					separatedBy: [stream nextPut: $/].
				(1 to: subnameCount) do: [
					aStream nextPut: $:.
					stream nextPutAll: (self readStringFrom: aStream)]]].
		[16] -> ["seems like RIDs are not serialized, so we just return a marker"
		#rid].
		[17] -> [ | objectId |
			self assert: (type bitAnd: (1 bitShift: 16)) ~= 0.
			objectId := aStream nextLittleEndianNumber: 8.
			objectId = 0 ifTrue: [nil] ifFalse: [GRObjectId new objectId: objectId]].
		[18] -> [ | count |
			count := (aStream nextLittleEndianNumber: 4) bitAnd: 2147483647.
			Dictionary newFrom: ((1 to: count) collect: [:index | (self readVariantFrom: aStream) -> (self readVariantFrom: aStream)])].
		[19] -> [ | count |
			count := (aStream nextLittleEndianNumber: 4) bitAnd: 2147483647.
			(1 to: count) collect: [:index | self readVariantFrom: aStream]].
		[20] -> [ | count ret pad |
			count := aStream nextLittleEndianNumber: 4.
			ret := aStream next: count.
			pad := count \\ 4 > 0 ifTrue: [4 - (count \\ 4)] ifFalse: [0].
			aStream next: pad.
			ret]}
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> start: aComponentClass [

	| listener |
	Current ifNotNil: [Current destroy].
	
	listener := self new.
	Current := listener.
	listener componentClass: aComponentClass.
	listener spawnListener.
	^ listener
]

{ #category : #'as yet unclassified' }
GRSocketListener class >> stopAll [

	Current destroy
]

{ #category : #communication }
GRSocketListener >> clearSessions [

	sessions do: [:s | s close].
	sessions removeAll
]

{ #category : #handlers }
GRSocketListener >> codeChanged: event [

	sessions do: [:session | session codeChanged: event]
]

{ #category : #accessing }
GRSocketListener >> componentClass [

	^ componentClass
]

{ #category : #accessing }
GRSocketListener >> componentClass: aClass [

	componentClass := aClass
]

{ #category : #communication }
GRSocketListener >> destroy [

	SystemChangeNotifier uniqueInstance noMoreNotificationsFor: self.
	
	listener destroy.
	process terminate.
	sessions do: #close
]

{ #category : #communication }
GRSocketListener >> handleConnection: aSocket [

	| stream session |
	stream := SocketStream on: aSocket.
	stream timeout: 100000.
	stream binary.
	
	session := GRSocketSession new
		socketStream: stream;
		reactComponent: self componentClass.
	"if you want to allow multiple sessions per image, disable this (enabled as it makes recovering from failed quit notifications easier)"
	self clearSessions.
	sessions at: session sessionId put: session.
	
	session spawnHandlerProcess
]

{ #category : #'initialize-release' }
GRSocketListener >> initialize [

	sessions := Dictionary new
]

{ #category : #communication }
GRSocketListener >> spawnListener [

	listener := Socket newTCP.
	listener listenOn: GRReact port backlogSize: 15.
	listener isWaitingForConnection ifFalse: [^ self error: 'Failed to connect'].
	
	SystemChangeNotifier uniqueInstance
		notify: self
		ofAllSystemChangesUsing: #codeChanged:.
	
	process := [
		[listener isValid] whileTrue: [(listener waitForAcceptFor: 10000000) ifNotNil: [:connection | self handleConnection: connection]].
		listener destroy]
		forkAt: Processor lowIOPriority
		named: '[Godot Socket Listener]'
]

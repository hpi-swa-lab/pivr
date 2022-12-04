Class {
	#name : #RtMIDI,
	#superclass : #ExternalLibrary,
	#instVars : [
		'out'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
RtMIDI class >> moduleName [

	^ 'rtmidi'
]

{ #category : #private }
RtMIDI >> assuredConnection [

	(out isNil or: [out isNull]) ifTrue: [
		out := self outCreate: 0 name: 'Squeak'.
		self assert: (out notNil and: [out isNull not]).
		self numPorts < 1
			ifTrue: [self open: out virtualPortNamed: 'squeak-virtual-out']
			ifFalse: [self open: out port: 1 name: 'squeak-out']].
	^ out
]

{ #category : #api }
RtMIDI >> chord: aCollection velocity: aVelocityNumber channel: aChannelNumber for: aDuration [

	aCollection do: [:note |
		self note: note velocity: aVelocityNumber channel: aChannelNumber for: aDuration]
]

{ #category : #ffi }
RtMIDI >> closePort: device [

	<apicall: void* rtmidi_close_port(void*)>
	^ self externalCallFailed
]

{ #category : #api }
RtMIDI >> control: aFirstNumber and: aSecondNumber channel: aChannelNumber [

	self assert: aChannelNumber < 16.
	self assert: aFirstNumber <= 127.
	self assert: aSecondNumber <= 127.
	self send: {(2r1011 bitShift: 4) bitOr: aChannelNumber. aFirstNumber. aSecondNumber}
]

{ #category : #api }
RtMIDI >> delete [

	(out notNil and: [out isNull not]) ifTrue: [self outFree: out]
]

{ #category : #ffi }
RtMIDI >> get: api port: aNumber nameInto: aString lengthPtr: aCollection [

	<apicall: long rtmidi_get_port_name(void*, ulong, char*, int*)>
	^ self externalCallFailed
]

{ #category : #private }
RtMIDI >> getPortName: aNumber [

	| len string |
	len := IntegerArray with: 0.
	self get: self assuredConnection port: aNumber nameInto: nil lengthPtr: len.
	
	string := ExternalType char allocateExternal: len first.
	self get: self assuredConnection port: aNumber nameInto: string lengthPtr: len.
	
	^ (string as: String) allButLast
]

{ #category : #api }
RtMIDI >> note: aNoteNumber velocity: aVelocityNumber channel: aChannelNumber for: aDuration [

	self noteOn: aNoteNumber velocity: aVelocityNumber channel: aChannelNumber.
	(self future: aDuration asMilliSeconds) noteOff: aNoteNumber velocity: 0 channel: aChannelNumber
]

{ #category : #api }
RtMIDI >> noteOff: aNoteNumber channel: aChannelNumber [

	self noteOff: aNoteNumber velocity: 0 channel: aChannelNumber
]

{ #category : #api }
RtMIDI >> noteOff: aNoteNumber velocity: aVelocityNumber channel: aChannelNumber [

	self assert: aChannelNumber < 16.
	self assert: aVelocityNumber <= 127.
	self assert: aNoteNumber <= 127.
	self send: {(8 bitShift: 4) bitOr: aChannelNumber. aNoteNumber. aVelocityNumber}
]

{ #category : #api }
RtMIDI >> noteOn: aNoteNumber velocity: aVelocityNumber channel: aChannelNumber [

	self assert: aChannelNumber < 16.
	self assert: aVelocityNumber <= 127.
	self assert: aNoteNumber <= 127.
	self send: {(9 bitShift: 4) bitOr: aChannelNumber. aNoteNumber. aVelocityNumber}
]

{ #category : #api }
RtMIDI >> numPorts [

	^ self portCount: self assuredConnection
]

{ #category : #ffi }
RtMIDI >> open: device port: aNumber name: aString [

	<apicall: void* rtmidi_open_port(void*, long, char*)>
	^ self externalCallFailed
]

{ #category : #ffi }
RtMIDI >> open: device virtualPortNamed: aString [

	<apicall: void* rtmidi_open_virtual_port(void*, char*)>
	^ self externalCallFailed
]

{ #category : #ffi }
RtMIDI >> outCreate: api name: aString [

	<apicall: void* rtmidi_out_create(long, char*)>
	^ self externalCallFailed
]

{ #category : #ffi }
RtMIDI >> outFree: device [

	<apicall: ulong rtmidi_out_free(void*)>
	^ self externalCallFailed
]

{ #category : #ffi }
RtMIDI >> outSend: device message: aString length: aNumber [

	<apicall: ulong rtmidi_out_send_message(void*, byte*, long)>
	^ self externalCallFailed
]

{ #category : #ffi }
RtMIDI >> portCount: device [

	<apicall: ulong rtmidi_get_port_count(void*)>
	^ self externalCallFailed
]

{ #category : #api }
RtMIDI >> programChange: aProgramNumber channel: aChannelNumber [

	self assert: aChannelNumber < 16.
	self assert: aProgramNumber <= 127.
	self send: {(12 bitShift: 4) bitOr: aChannelNumber. aProgramNumber}
]

{ #category : #api }
RtMIDI >> reset [

	self send: {16rff}
]

{ #category : #private }
RtMIDI >> send: aCollection [

	self outSend: self assuredConnection message: aCollection asByteArray length: aCollection size
]

{ #category : #api }
RtMIDI >> toggleSustainPedal: aBoolean channel: aChannelNumber [

	self control: 64 and: (aBoolean ifTrue: [64] ifFalse: [0]) channel: aChannelNumber
]

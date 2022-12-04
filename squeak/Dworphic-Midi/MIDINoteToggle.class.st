Class {
	#name : #MIDINoteToggle,
	#superclass : #MIDINote,
	#instVars : [
		'playing',
		'duration'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDINoteToggle >> atBeat [

	^ playing ifNotNil: [super atBeat + self duration] ifNil: [super atBeat]
]

{ #category : #'as yet unclassified' }
MIDINoteToggle >> duration [

	^ duration
]

{ #category : #'as yet unclassified' }
MIDINoteToggle >> duration: aNumber [

	duration := aNumber
]

{ #category : #'as yet unclassified' }
MIDINoteToggle >> endBeat [

	^ self atBeat + self duration
]

{ #category : #'as yet unclassified' }
MIDINoteToggle >> playWith: anObject [

	playing
		ifNotNil: [
			self player noteOff: playing velocity: self velocity channel: anObject channel.
			playing := nil]
		ifNil: [
			playing := self note.
			self player noteOn: playing velocity: self velocity channel: anObject channel]
]

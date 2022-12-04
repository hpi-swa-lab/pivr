Class {
	#name : #MIDIEvent,
	#superclass : #MIDINode,
	#instVars : [
		'atMilliseconds',
		'atBeat'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDIEvent >> atBeat [

	^ atBeat
]

{ #category : #'as yet unclassified' }
MIDIEvent >> atBeat: aNumber [

	atBeat := aNumber
]

{ #category : #'as yet unclassified' }
MIDIEvent >> endBeat [

	^ self atBeat
]

{ #category : #'as yet unclassified' }
MIDIEvent >> playWith: anObject [

	
]

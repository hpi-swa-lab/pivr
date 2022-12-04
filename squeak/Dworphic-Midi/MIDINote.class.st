Class {
	#name : #MIDINote,
	#superclass : #MIDIEvent,
	#instVars : [
		'note',
		'velocity'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDINote >> initialize [

	super initialize.
	
	self velocity: 64
]

{ #category : #'as yet unclassified' }
MIDINote >> note [

	^ note
]

{ #category : #'as yet unclassified' }
MIDINote >> note: aNumber [

	note := aNumber
]

{ #category : #'as yet unclassified' }
MIDINote >> velocity [

	^ velocity
]

{ #category : #'as yet unclassified' }
MIDINote >> velocity: aNumber [

	velocity := aNumber
]

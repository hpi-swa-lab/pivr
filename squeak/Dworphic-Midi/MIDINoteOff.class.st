Class {
	#name : #MIDINoteOff,
	#superclass : #MIDINote,
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDINoteOff >> playWith: anObject [

	self player noteOff: self note velocity: self velocity channel: anObject channel
]

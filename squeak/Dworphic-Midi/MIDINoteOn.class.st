Class {
	#name : #MIDINoteOn,
	#superclass : #MIDINote,
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDINoteOn >> playWith: anObject [

	self player noteOn: self note velocity: self velocity channel: anObject channel
]

Class {
	#name : #MIDIScale,
	#superclass : #Object,
	#instVars : [
		'base',
		'steps'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDIScale class >> major: aBaseNote [

	^ self new
		steps: #(0 2 4 5 7 9 11);
		base: aBaseNote
]

{ #category : #'as yet unclassified' }
MIDIScale class >> minor: aBaseNote [

	^ self new
		steps: #(0 2 3 5 7 8 10);
		base: aBaseNote
]

{ #category : #'as yet unclassified' }
MIDIScale class >> pentatonic: aBaseNumber [

	^ self new
		steps: #(0 3 5 7 10);
		base: aBaseNumber
]

{ #category : #'as yet unclassified' }
MIDIScale >> * aNumber [

	| allSteps |
	allSteps := self steps.
	aNumber timesRepeat: [allSteps := allSteps, ((allSteps last: self steps size) collect: [:s | s + 12])].
	^ self copy
		base: self base;
		steps: allSteps
]

{ #category : #'as yet unclassified' }
MIDIScale >> atRandom [

	^ self base + self steps atRandom
]

{ #category : #'as yet unclassified' }
MIDIScale >> base [

	^ base
]

{ #category : #'as yet unclassified' }
MIDIScale >> base: aNumber [

	base := aNumber
]

{ #category : #'as yet unclassified' }
MIDIScale >> steps [

	^ steps
]

{ #category : #'as yet unclassified' }
MIDIScale >> steps: aCollection [

	steps := aCollection
]

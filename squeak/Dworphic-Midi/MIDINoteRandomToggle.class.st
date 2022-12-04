Class {
	#name : #MIDINoteRandomToggle,
	#superclass : #MIDINoteToggle,
	#instVars : [
		'choices'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDINoteRandomToggle >> choices: aCollection [

	choices := aCollection
]

{ #category : #'as yet unclassified' }
MIDINoteRandomToggle >> note [

	^ choices atRandom
]

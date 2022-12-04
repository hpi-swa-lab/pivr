Class {
	#name : #MIDILoop,
	#superclass : #MIDINode,
	#instVars : [
		'startTime',
		'lastCheck',
		'channel',
		'completed'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDILoop >> channel [

	^ channel
]

{ #category : #'as yet unclassified' }
MIDILoop >> channel: aNumber [

	channel := aNumber
]

{ #category : #'as yet unclassified' }
MIDILoop >> duration [

	^ (self children collect: [:c | self player beatToMillisecondOffset: c endBeat]) max
]

{ #category : #'as yet unclassified' }
MIDILoop >> initialize [

	super initialize.
	
	completed := true
]

{ #category : #'as yet unclassified' }
MIDILoop >> step [

	| start end delta |
	startTime ifNil: [^ self].
	completed ifFalse: [^ self].
	
	start := lastCheck.
	end := Time millisecondClock - startTime.
	self children do: [:child | | atMilliseconds |
		atMilliseconds := self player beatToMillisecondOffset: child atBeat.
		(atMilliseconds >= start and: [atMilliseconds < end]) ifTrue: [child playWith: self]].
	lastCheck := end.
	
	delta := end - self duration.
	delta > 0 ifTrue: [
		completed := true.
		startTime := Time millisecondClock + delta.
		lastCheck := delta negated]
]

{ #category : #'as yet unclassified' }
MIDILoop >> stepDownBeat: aTimeInMilliseconds delta: aDeltaNumber [

	(SBWatch report: completed for: 992557222) ifFalse: [^ self].
	startTime := aTimeInMilliseconds.
	lastCheck := aDeltaNumber negated
]

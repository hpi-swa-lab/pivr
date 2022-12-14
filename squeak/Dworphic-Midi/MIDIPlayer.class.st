Class {
	#name : #MIDIPlayer,
	#superclass : #MIDINode,
	#instVars : [
		'midi',
		'process',
		'bpm',
		'beat',
		'lastMeasureStart',
		'channelMapping'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDIPlayer >> addChild: aNode [

	super addChild: aNode.
	aNode allChildrenDo: [:c | c addedToPlayer: self]
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> beat [

	^ beat
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> beat: aNumber [

	beat := aNumber
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> beatToMillisecondOffset: aBeat [

	^ self measureLengthMilliseconds * aBeat
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> bpm [

	^ bpm
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> bpm: aNumber [

	bpm := aNumber
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> channel: anObject do: aBlock [

	^ anObject isNumber
		ifTrue: [aBlock value: anObject]
		ifFalse: [(channelMapping value: anObject) ifNotNil: [:c | aBlock value: c]]
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> channelMapping: aBlock [

	channelMapping := aBlock
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> initialize [

	super initialize.
	
	bpm := 120.
	beat := 1 / 4
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> measureLengthMilliseconds [

	^ self beat reciprocal / (self bpm / 60) * 1000
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> noteOff: aNoteNumber velocity: aVelocityNumber channel: aChannelNumber [

	self
		channel: aChannelNumber
		do: [:channel | midi noteOff: aNoteNumber velocity: aVelocityNumber channel: channel]
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> noteOn: aNoteNumber velocity: aVelocityNumber channel: aChannelNumber [

	self
		channel: aChannelNumber
		do: [:channel | midi noteOn: aNoteNumber velocity: aVelocityNumber channel: channel]
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> player [

	^ self
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> programChange: aProgramNumber channel: aChannelNumber [

	self channel: aChannelNumber do: [:channel | midi programChange: aProgramNumber channel: channel]
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> start [

	self stop.
	
	midi := RtMIDI new.
	lastMeasureStart := Time millisecondClock.
	process := [
		[
			self allChildrenDo: [:c | c step].
			10 milliSeconds wait] repeat] forkAt: Processor userBackgroundPriority
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> step [

	| measureLength now delta |
	measureLength := self measureLengthMilliseconds.
	now := Time millisecondClock.
	
	delta := now - (lastMeasureStart + measureLength).
	delta >= 0 ifTrue: [
		lastMeasureStart := now - delta.
		self allChildrenDo: [:c | c stepDownBeat: lastMeasureStart delta: delta]]
]

{ #category : #'as yet unclassified' }
MIDIPlayer >> stop [

	process ifNotNil: #terminate.
	process := nil.
	midi ifNotNil: #delete.
	midi := nil
]

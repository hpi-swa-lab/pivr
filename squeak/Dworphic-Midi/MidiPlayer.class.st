Class {
	#name : #MidiPlayer,
	#superclass : #GRComponent,
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MidiPlayer class >> appDescription [

	<home>
	^ super appDescription
]

{ #category : #'as yet unclassified' }
MidiPlayer >> playNote: midi [

	midi note: 59 velocity: 107 channel: 0 for: 35 milliSeconds
]

{ #category : #'as yet unclassified' }
MidiPlayer >> render: props [

	| midi |
	midi := self useState: nil.
	self
		useSingletonEffect: [
			midi set: RtMIDI new.
			[midi get delete]]
		dependencies: {}.
	
	^ midi get ifNotNil: [
		GDTimer new
			autostart: true;
			waitTime: 0.8;
			onTimeout: [self playNote: midi get]]
]

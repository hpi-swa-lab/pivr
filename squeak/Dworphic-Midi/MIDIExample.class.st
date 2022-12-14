Class {
	#name : #MIDIExample,
	#superclass : #MIDIComponent,
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDIExample >> render: props [

	| player |
	player := props at: #player.
	
	self
		useEffect: [
			player bpm: 120.
			player programChange: 8 channel: 1.
			player programChange: 33 channel: 3]
		dependencies: {}.
	
	^ self class instrumentsMethods collect: [:m | (self methodAsComponent: m selector) channel: m selector]
]

{ #category : #'as yet unclassified' }
MIDIExample >> renderBass: props [

	^ self loop: 4 of: (MIDIScale pentatonic: self a3) for: 1 / 4 channel: (props at: #channel)
]

{ #category : #'as yet unclassified' }
MIDIExample >> renderDrums: props [

	^ self
		loop: {
			self bassDrumFor: 1 / 4.
			self accousticSnareFor: 1 / 4.
			self bassDrumFor: 1 / 4.
			self accousticSnareFor: 1 / 4}
		channel: (props at: #channel)
]

{ #category : #'as yet unclassified' }
MIDIExample >> renderMelody: props [

	^ self loop: 4 of: (MIDIScale pentatonic: self a5) * 2 for: 1 / 8 channel: (props at: #channel)
]

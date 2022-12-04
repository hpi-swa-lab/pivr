Class {
	#name : #MIDIExample,
	#superclass : #MIDIComponent,
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDIExample class >> generateNoteMethods [

	| names order |
	names := #(#c #cs #d #ds #e #f #fs #g #gs #a #as #b).
	order := 1.
	12 to: 119 by: names size do: [:midi |
		names do: [:name | self compile: ('{1}{2}

	^ {3}' format: {name. order. midi}) classified: 'notes'].
		order := order + 1]
]

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
	
	^ {
		self
			loop: {
				self bassDrumFor: 1 / 4.
				self accousticSnareFor: 1 / 4.
				self bassDrumFor: 1 / 4.
				self accousticSnareFor: 1 / 4}
			channel: 9.
		self loop: 4 of: (MIDIScale pentatonic: self a5) * 2 for: 1 / 8 channel: 1.
		self loop: 4 of: (MIDIScale pentatonic: self a3) for: 1 / 4 channel: 3}
]

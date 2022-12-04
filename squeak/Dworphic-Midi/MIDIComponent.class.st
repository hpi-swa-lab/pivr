Class {
	#name : #MIDIComponent,
	#superclass : #CMFReactComponent,
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDIComponent class >> generateNoteMethods [

	| names order |
	names := #(#c #cs #d #ds #e #f #fs #g #gs #a #as #b).
	order := 1.
	12 to: 119 by: names size do: [:midi |
		names do: [:name | self compile: ('{1}{2}

	^ {3}' format: {name. order. midi}) classified: 'notes'].
		order := order + 1]
]

{ #category : #'as yet unclassified' }
MIDIComponent class >> start [

	| react |
	react := MIDIReact new component: self new.
	react start.
	^ react
]

{ #category : #notes }
MIDIComponent >> a1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> a2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> a3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> a4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> a5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> a6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> a7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> a8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> a9 [

	^ 108
]

{ #category : #drums }
MIDIComponent >> accousticBassDrumFor: aNumber [

	^ self note: 35 for: aNumber
]

{ #category : #drums }
MIDIComponent >> accousticSnareFor: aNumber [

	^ self note: 38 for: aNumber
]

{ #category : #notes }
MIDIComponent >> as1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> as2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> as3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> as4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> as5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> as6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> as7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> as8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> as9 [

	^ 108
]

{ #category : #notes }
MIDIComponent >> b1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> b2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> b3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> b4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> b5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> b6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> b7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> b8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> b9 [

	^ 108
]

{ #category : #drums }
MIDIComponent >> bassDrumFor: aNumber [

	^ self note: 36 for: aNumber
]

{ #category : #notes }
MIDIComponent >> c1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> c2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> c3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> c4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> c5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> c6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> c7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> c8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> c9 [

	^ 108
]

{ #category : #drums }
MIDIComponent >> closedHiHatFor: aNumber [

	^ self note: 42 for: aNumber
]

{ #category : #drums }
MIDIComponent >> cowbellFor: aNumber [

	^ self note: 56 for: aNumber
]

{ #category : #notes }
MIDIComponent >> cs1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> cs2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> cs3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> cs4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> cs5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> cs6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> cs7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> cs8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> cs9 [

	^ 108
]

{ #category : #notes }
MIDIComponent >> d1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> d2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> d3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> d4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> d5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> d6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> d7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> d8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> d9 [

	^ 108
]

{ #category : #notes }
MIDIComponent >> ds1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> ds2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> ds3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> ds4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> ds5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> ds6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> ds7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> ds8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> ds9 [

	^ 108
]

{ #category : #notes }
MIDIComponent >> e1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> e2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> e3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> e4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> e5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> e6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> e7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> e8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> e9 [

	^ 108
]

{ #category : #notes }
MIDIComponent >> f1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> f2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> f3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> f4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> f5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> f6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> f7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> f8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> f9 [

	^ 108
]

{ #category : #notes }
MIDIComponent >> fs1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> fs2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> fs3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> fs4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> fs5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> fs6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> fs7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> fs8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> fs9 [

	^ 108
]

{ #category : #notes }
MIDIComponent >> g1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> g2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> g3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> g4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> g5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> g6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> g7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> g8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> g9 [

	^ 108
]

{ #category : #notes }
MIDIComponent >> gs1 [

	^ 12
]

{ #category : #notes }
MIDIComponent >> gs2 [

	^ 24
]

{ #category : #notes }
MIDIComponent >> gs3 [

	^ 36
]

{ #category : #notes }
MIDIComponent >> gs4 [

	^ 48
]

{ #category : #notes }
MIDIComponent >> gs5 [

	^ 60
]

{ #category : #notes }
MIDIComponent >> gs6 [

	^ 72
]

{ #category : #notes }
MIDIComponent >> gs7 [

	^ 84
]

{ #category : #notes }
MIDIComponent >> gs8 [

	^ 96
]

{ #category : #notes }
MIDIComponent >> gs9 [

	^ 108
]

{ #category : #'as yet unclassified' }
MIDIComponent >> loop: aCollection channel: aNumber [

	| time |
	time := 0.
	^ MIDIReactNode new
		tag: MIDILoop;
		channel: aNumber;
		children: (aCollection gather: [:note |
			time := time + note duration.
			note note > 0
				ifTrue: [
					{
						MIDIReactNode new
							tag: MIDINoteOn;
							note: note note;
							atBeat: time - note duration.
						MIDIReactNode new
							tag: MIDINoteOff;
							note: note note;
							atBeat: time}]
				ifFalse: [
					{
						MIDIReactNode new
							tag: MIDIEvent;
							atBeat: time}]])
]

{ #category : #'as yet unclassified' }
MIDIComponent >> loop: aCountNumber of: aCollection for: aDurationNumber channel: aNumber [

	| time |
	time := 0.
	^ MIDIReactNode new
		tag: MIDILoop;
		channel: aNumber;
		children: ((1 to: aCountNumber) collect: [:note |
			time := time + aDurationNumber.
			MIDIReactNode new
				tag: MIDINoteRandomToggle;
				choices: aCollection;
				duration: aDurationNumber;
				atBeat: time - aDurationNumber])
]

{ #category : #'as yet unclassified' }
MIDIComponent >> note: aNote for: aNumber [

	^ MIDIReactNode new
		tag: MIDINote;
		note: aNote;
		duration: aNumber
]

{ #category : #drums }
MIDIComponent >> openHiHatFor: aNumber [

	^ self note: 46 for: aNumber
]

{ #category : #'as yet unclassified' }
MIDIComponent >> restFor: aNumber [

	^ self note: 0 for: aNumber
]

{ #category : #drums }
MIDIComponent >> sideStickFor: aNumber [

	^ self note: 37 for: aNumber
]

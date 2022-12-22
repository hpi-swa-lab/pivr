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
		names withIndexDo: [:name :index | self compile: ('{1}{2}

	^ {3}' format: {name. order. midi + (index - 1)}) classified: 'notes'].
		order := order + 1]
]

{ #category : #'as yet unclassified' }
MIDIComponent class >> instrumentsMethods [

	^ self methodDict values select: [:m | (m selector beginsWith: 'render') and: [m selector size > 7]]
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

	^ 21
]

{ #category : #notes }
MIDIComponent >> a2 [

	^ 33
]

{ #category : #notes }
MIDIComponent >> a3 [

	^ 45
]

{ #category : #notes }
MIDIComponent >> a4 [

	^ 57
]

{ #category : #notes }
MIDIComponent >> a5 [

	^ 69
]

{ #category : #notes }
MIDIComponent >> a6 [

	^ 81
]

{ #category : #notes }
MIDIComponent >> a7 [

	^ 93
]

{ #category : #notes }
MIDIComponent >> a8 [

	^ 105
]

{ #category : #notes }
MIDIComponent >> a9 [

	^ 117
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

	^ 22
]

{ #category : #notes }
MIDIComponent >> as2 [

	^ 34
]

{ #category : #notes }
MIDIComponent >> as3 [

	^ 46
]

{ #category : #notes }
MIDIComponent >> as4 [

	^ 58
]

{ #category : #notes }
MIDIComponent >> as5 [

	^ 70
]

{ #category : #notes }
MIDIComponent >> as6 [

	^ 82
]

{ #category : #notes }
MIDIComponent >> as7 [

	^ 94
]

{ #category : #notes }
MIDIComponent >> as8 [

	^ 106
]

{ #category : #notes }
MIDIComponent >> as9 [

	^ 118
]

{ #category : #notes }
MIDIComponent >> b1 [

	^ 23
]

{ #category : #notes }
MIDIComponent >> b2 [

	^ 35
]

{ #category : #notes }
MIDIComponent >> b3 [

	^ 47
]

{ #category : #notes }
MIDIComponent >> b4 [

	^ 59
]

{ #category : #notes }
MIDIComponent >> b5 [

	^ 71
]

{ #category : #notes }
MIDIComponent >> b6 [

	^ 83
]

{ #category : #notes }
MIDIComponent >> b7 [

	^ 95
]

{ #category : #notes }
MIDIComponent >> b8 [

	^ 107
]

{ #category : #notes }
MIDIComponent >> b9 [

	^ 119
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

	^ 13
]

{ #category : #notes }
MIDIComponent >> cs2 [

	^ 25
]

{ #category : #notes }
MIDIComponent >> cs3 [

	^ 37
]

{ #category : #notes }
MIDIComponent >> cs4 [

	^ 49
]

{ #category : #notes }
MIDIComponent >> cs5 [

	^ 61
]

{ #category : #notes }
MIDIComponent >> cs6 [

	^ 73
]

{ #category : #notes }
MIDIComponent >> cs7 [

	^ 85
]

{ #category : #notes }
MIDIComponent >> cs8 [

	^ 97
]

{ #category : #notes }
MIDIComponent >> cs9 [

	^ 109
]

{ #category : #notes }
MIDIComponent >> d1 [

	^ 14
]

{ #category : #notes }
MIDIComponent >> d2 [

	^ 26
]

{ #category : #notes }
MIDIComponent >> d3 [

	^ 38
]

{ #category : #notes }
MIDIComponent >> d4 [

	^ 50
]

{ #category : #notes }
MIDIComponent >> d5 [

	^ 62
]

{ #category : #notes }
MIDIComponent >> d6 [

	^ 74
]

{ #category : #notes }
MIDIComponent >> d7 [

	^ 86
]

{ #category : #notes }
MIDIComponent >> d8 [

	^ 98
]

{ #category : #notes }
MIDIComponent >> d9 [

	^ 110
]

{ #category : #notes }
MIDIComponent >> ds1 [

	^ 15
]

{ #category : #notes }
MIDIComponent >> ds2 [

	^ 27
]

{ #category : #notes }
MIDIComponent >> ds3 [

	^ 39
]

{ #category : #notes }
MIDIComponent >> ds4 [

	^ 51
]

{ #category : #notes }
MIDIComponent >> ds5 [

	^ 63
]

{ #category : #notes }
MIDIComponent >> ds6 [

	^ 75
]

{ #category : #notes }
MIDIComponent >> ds7 [

	^ 87
]

{ #category : #notes }
MIDIComponent >> ds8 [

	^ 99
]

{ #category : #notes }
MIDIComponent >> ds9 [

	^ 111
]

{ #category : #notes }
MIDIComponent >> e1 [

	^ 16
]

{ #category : #notes }
MIDIComponent >> e2 [

	^ 28
]

{ #category : #notes }
MIDIComponent >> e3 [

	^ 40
]

{ #category : #notes }
MIDIComponent >> e4 [

	^ 52
]

{ #category : #notes }
MIDIComponent >> e5 [

	^ 64
]

{ #category : #notes }
MIDIComponent >> e6 [

	^ 76
]

{ #category : #notes }
MIDIComponent >> e7 [

	^ 88
]

{ #category : #notes }
MIDIComponent >> e8 [

	^ 100
]

{ #category : #notes }
MIDIComponent >> e9 [

	^ 112
]

{ #category : #notes }
MIDIComponent >> f1 [

	^ 17
]

{ #category : #notes }
MIDIComponent >> f2 [

	^ 29
]

{ #category : #notes }
MIDIComponent >> f3 [

	^ 41
]

{ #category : #notes }
MIDIComponent >> f4 [

	^ 53
]

{ #category : #notes }
MIDIComponent >> f5 [

	^ 65
]

{ #category : #notes }
MIDIComponent >> f6 [

	^ 77
]

{ #category : #notes }
MIDIComponent >> f7 [

	^ 89
]

{ #category : #notes }
MIDIComponent >> f8 [

	^ 101
]

{ #category : #notes }
MIDIComponent >> f9 [

	^ 113
]

{ #category : #notes }
MIDIComponent >> fs1 [

	^ 18
]

{ #category : #notes }
MIDIComponent >> fs2 [

	^ 30
]

{ #category : #notes }
MIDIComponent >> fs3 [

	^ 42
]

{ #category : #notes }
MIDIComponent >> fs4 [

	^ 54
]

{ #category : #notes }
MIDIComponent >> fs5 [

	^ 66
]

{ #category : #notes }
MIDIComponent >> fs6 [

	^ 78
]

{ #category : #notes }
MIDIComponent >> fs7 [

	^ 90
]

{ #category : #notes }
MIDIComponent >> fs8 [

	^ 102
]

{ #category : #notes }
MIDIComponent >> fs9 [

	^ 114
]

{ #category : #notes }
MIDIComponent >> g1 [

	^ 19
]

{ #category : #notes }
MIDIComponent >> g2 [

	^ 31
]

{ #category : #notes }
MIDIComponent >> g3 [

	^ 43
]

{ #category : #notes }
MIDIComponent >> g4 [

	^ 55
]

{ #category : #notes }
MIDIComponent >> g5 [

	^ 67
]

{ #category : #notes }
MIDIComponent >> g6 [

	^ 79
]

{ #category : #notes }
MIDIComponent >> g7 [

	^ 91
]

{ #category : #notes }
MIDIComponent >> g8 [

	^ 103
]

{ #category : #notes }
MIDIComponent >> g9 [

	^ 115
]

{ #category : #notes }
MIDIComponent >> gs1 [

	^ 20
]

{ #category : #notes }
MIDIComponent >> gs2 [

	^ 32
]

{ #category : #notes }
MIDIComponent >> gs3 [

	^ 44
]

{ #category : #notes }
MIDIComponent >> gs4 [

	^ 56
]

{ #category : #notes }
MIDIComponent >> gs5 [

	^ 68
]

{ #category : #notes }
MIDIComponent >> gs6 [

	^ 80
]

{ #category : #notes }
MIDIComponent >> gs7 [

	^ 92
]

{ #category : #notes }
MIDIComponent >> gs8 [

	^ 104
]

{ #category : #notes }
MIDIComponent >> gs9 [

	^ 116
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

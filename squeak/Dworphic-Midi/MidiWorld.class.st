Class {
	#name : #MidiWorld,
	#superclass : #GRComponent,
	#category : #'Dworphic-Midi-World'
}

{ #category : #'as yet unclassified' }
MidiWorld >> channelCount [

	^ 5
]

{ #category : #'as yet unclassified' }
MidiWorld >> render: props [

	| midiReact channelMapping eventQueue instruments |
	midiReact := self useState: [MIDIExample start].
	eventQueue := self useRef: nil.
	channelMapping := self useState: Dictionary new.
	instruments := midiReact get component elementClass instrumentsMethods collect: [:m | m selector].
	
	self
		useSingletonEffect: [ | newQueue |
			newQueue := SharedQueue new.
			eventQueue set: newQueue.
			midiReact get onMidiEvent: [:newEvent | newQueue nextPut: newEvent].
			[midiReact get stop]]
		dependencies: #().
	
	self useEffect: [
		eventQueue get ifNotNil: [:queue |
			[ | event |
				event := queue nextOrNil.
				event ifNotNil: [Transcript showln: event].
				event notNil] whileTrue]].
	
	self
		useEffect: [
			midiReact get channelMapping: channelMapping get.
			Transcript showln: channelMapping get]
		dependencies: {channelMapping get}.
	
	^ ApplicationDworph new children: {
		GRProvider
			values: {
				#channelAreas -> (self useRef: Dictionary new) get.
				#channelMapping -> channelMapping get.
				#setChannelMapping -> channelMapping setter}
			children: {
				GDStaticBody new
					translation: 0 @ -1 m @ 0;
					children: {GDCollisionShape new shape: (GDBoxShape new extents: 10 m @ 1 m @ 10 m)}, ((1 to: self channelCount) collect: [:channel | | angle pointXY |
						angle := 360 / self channelCount * channel.
						pointXY := Point r: 2 degrees: angle.
						MidiChannelArea new
							translation: pointXY x @ 0 @ pointXY y;
							channel: channel]), (instruments collect: [:instrument |
						MidiBlock new
							instrument: instrument;
							key: instrument])}}
]

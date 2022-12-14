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
	midiReact := self useRef: MIDIReact new.
	eventQueue := self useRef: nil.
	channelMapping := self useState: Dictionary new.
	instruments := self useState: #().
	
	self useSingletonEffect: [ | newQueue |
		newQueue := SharedQueue new.
		eventQueue set: newQueue.
		midiReact get onMidiEvent: [:newEvent | newQueue nextPut: newEvent].
		"instruments set: midiRect get instruments."
		instruments set: #(1).
		"midiReact get start." "UNCOMMENT THIS"
		(instruments get) do: [:instrument | channelMapping get at: instrument put: nil].
		["midiReact get stop" "UNCOMMENT THIS"]] dependencies: #().

	self useEffect: [
		eventQueue get ifNotNil: [:queue |
			[| event |
				event := queue nextOrNil.
				event ifNotNil: [Transcript showln: event].
				event notNil] whileTrue]].
	
	self useEffect: [
		midiReact get channelMapping: channelMapping get.
		Transcript showln: channelMapping get]
		dependencies: {channelMapping get}.

	^ ApplicationDworph new
		children: {
			GRProvider
				values: {
					#channelAreas -> (self useRef: Dictionary new) get.
					#channelMapping -> (channelMapping get).
					#setChannelMapping -> (channelMapping setter)}
				children: {
					GDStaticBody new
						translation: 0 @ -1m @ 0;
						children: {
							GDCollisionShape new
								shape: (GDBoxShape new
									extents: 10m @ 1m @ 10m)},
					((1 to: self channelCount) collect: [:channel | | angle pointXY |
						angle := (360 / self channelCount) * channel.
						pointXY := Point r: 2 degrees: angle.
						MidiChannelArea new
							translation: pointXY x @ 0 @ pointXY y;
							channel: channel]),
					(instruments get collect: [:instrument |
						MidiBlock new
							instrument: instrument])}}
		
		
]

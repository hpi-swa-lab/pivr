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

	| midiReact channelMapping instruments channelAreas layoutParams editor |
	channelAreas := self useRef: Dictionary new.
	midiReact := self useState: [MIDIExample start].
	channelMapping := self useState: Dictionary new.
	instruments := self useState: Dictionary new.
	layoutParams := CodeBlockLayoutParamters new
		blockDepth: 0.01;
		morphicScale: 0.003.
	
	self useSingletonEffect: [[midiReact get stop]] dependencies: #().
	
	self
		useEffect: [
			midiReact get channelMapping: channelMapping get.
			Transcript showln: channelMapping get]
		dependencies: {channelMapping get}.
	self useEffect: [ | all |
		all := midiReact get component elementClass instrumentsMethods collect: [:m | m selector].
		all do: [:name |
			instruments get at: name ifAbsent: [
				instruments set: [:i |
					i copy
						at: name put: (Matrix4x4 withOffset: 0 @ 1 @ 0);
						yourself]]]].
	
	editor := self useMemo: [SBEditor new] dependencies: {}.
	
	self
		useEffect: [instruments get keys do: [:i | editor openMorph: (SBTSStMethod for: MIDIExample >> i)]]
		dependencies: {instruments get size}.
	self
		useEffect: [
			instruments get keysAndValuesDo: [:instrument :transform |
				editor childSandblocks
					detect: [:c | c selector = instrument]
					ifFound: [:c | c setProperty: #vrTransform toValue: transform]]]
		dependencies: {instruments get}.
	
	^ ApplicationDworph new children: {
		GRProvider values: {#channelAreas -> channelAreas get} children: {
			GDStaticBody new
				translation: 0 @ -1 m @ 0;
				children: {GDCollisionShape new shape: (GDBoxShape new extents: 10 m @ 1 m @ 10 m)}, ((1 to: self channelCount) collect: [:channel | | angle pointXY |
					angle := 360 / self channelCount * channel.
					pointXY := Point r: 2 degrees: angle.
					MidiChannelArea new
						translation: pointXY x @ 0 @ pointXY y;
						channel: channel]), {
					BlockCodeEditor new
						editor: editor;
						layoutParams: layoutParams}, (instruments get associations collect: [:instrument |
					MidiBlock new
						instrument: instrument key;
						globalTransform: instrument value;
						onAssignChannel: [:channel | channelMapping set: [:old | old copyAt: instrument key put: channel]];
						onTransform: [:transform | instruments set: [:i | i copyAt: instrument key put: transform]];
						key: instrument key])}}
]

{ #category : #'as yet unclassified' }
MidiWorld >> useEventQueue: midiReact [

	| eventQueue |
	eventQueue := self useRef: nil.
	self
		useSingletonEffect: [ | newQueue |
			newQueue := SharedQueue new.
			midiReact get onMidiEvent: [:newEvent | newQueue nextPut: newEvent].
			eventQueue set: newQueue]
		dependencies: #().
	self useEffect: [
		eventQueue get ifNotNil: [:queue |
			[ | event |
				event := queue nextOrNil.
				event ifNotNil: [Transcript showln: event].
				event notNil] whileTrue]]
]

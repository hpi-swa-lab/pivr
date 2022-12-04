Class {
	#name : #MIDIReact,
	#superclass : #Object,
	#instVars : [
		'player',
		'react'
	],
	#category : #'Dworphic-Midi'
}

{ #category : #'as yet unclassified' }
MIDIReact >> codeChanged: event [

	event isDoIt ifTrue: [^ self].
	
	react codeChanged: event
]

{ #category : #'as yet unclassified' }
MIDIReact >> component: aComponent [

	player := MIDIPlayer new.
	react := CMFReactWithFibers new
		hostConfig: CMFHostConfigMidi new;
		renderRoot: (aComponent player: player) in: player
]

{ #category : #'as yet unclassified' }
MIDIReact >> start [

	player start.
	react reRenderAll.
	
	SystemChangeNotifier uniqueInstance
		notify: self
		ofAllSystemChangesUsing: #codeChanged:
]

{ #category : #'as yet unclassified' }
MIDIReact >> stop [

	SystemChangeNotifier uniqueInstance noMoreNotificationsFor: self.
	player stop
]

Class {
	#name : #SBGodotSuggestionMenu,
	#superclass : #SBSuggestionMenu,
	#instVars : [
		'currentSuggestions'
	],
	#category : #'GS-VR-Editor'
}

{ #category : #'as yet unclassified' }
SBGodotSuggestionMenu >> delete [

	SBVREditor current godotProvider ifNotNil: [:p | p updateSuggestions: #() asJsonString].
	super delete.
]

{ #category : #'as yet unclassified' }
SBGodotSuggestionMenu >> suggestionAt: index [

	^ currentSuggestions at: index
]

{ #category : #'as yet unclassified' }
SBGodotSuggestionMenu >> suggestions: aCollectionOfSymbols [
	
	super suggestions: aCollectionOfSymbols.
	currentSuggestions := aCollectionOfSymbols.
	SBVREditor current godotProvider  ifNotNil: [:p | p updateSuggestions: self suggestionsInfo asJsonString]
]

{ #category : #'as yet unclassified' }
SBGodotSuggestionMenu >> suggestionsInfo [

	^ currentSuggestions collect: [:suggestion |
		{#name -> suggestion selector} as: Dictionary]
]

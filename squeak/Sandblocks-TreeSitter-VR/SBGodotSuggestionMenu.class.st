Class {
	#name : #SBGodotSuggestionMenu,
	#superclass : #SBSuggestionMenu,
	#instVars : [
		'currentSuggestions'
	],
	#category : #'Sandblocks-TreeSitter-VR'
}

{ #category : #'as yet unclassified' }
SBGodotSuggestionMenu >> delete [

	SBVREditor current godotProvider updateSuggestions: #() asJsonString.
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
	SBVREditor current godotProvider updateSuggestions: self suggestionsInfo asJsonString
]

{ #category : #'as yet unclassified' }
SBGodotSuggestionMenu >> suggestionsInfo [

	^ currentSuggestions collect: [:suggestion |
		{#name -> suggestion selector} as: Dictionary]
]

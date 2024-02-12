Class {
	#name : #ComponentBrowser,
	#superclass : #Model,
	#instVars : [
		'currentSelection',
		'rootFiber'
	],
	#category : #'GReaSe-Tools'
}

{ #category : #'as yet unclassified' }
ComponentBrowser class >> displayHooksForFiber: aCMFFiber [

	^ aCMFFiber hooks collect: [:hook | | hookString |
			hookString := (hook className) copyReplaceAll: 'CMFReactHook' with: '' asTokens: false.
			(hook instVarNamed: 'hookName') ifNotNil: [hookString := hookString , ' ', (hook instVarNamed: 'hookName') asString].
			[(hook instVarNamed: 'state') ifNotNil: [hookString := hookString , ': ', (hook instVarNamed: 'state') asString]] ifError: [hookString := hookString , ''].
			]
]

{ #category : #'as yet unclassified' }
ComponentBrowser class >> displayPropsForFiber: aCMFFiber [

	^ aCMFFiber node isGodotNode
			ifTrue: [aCMFFiber node properties associations collect: [:assoc | assoc asString]]
			ifFalse: {'<>'}
]

{ #category : #'as yet unclassified' }
ComponentBrowser class >> displayTempsForFiber: aCMFFiber [

	^ (aCMFFiber node isGodotNode
			ifTrue: {'<is Godot node>' }
			ifFalse: [ 
				(aCMFFiber node isKindOf: CMFRootNode) ifTrue: {'<is root node>'} ifFalse: [
					[
					| parser |
					parser := PPParser new
							parse: (aCMFFiber node elementClass>>#render:) getSource
							class: UndefinedObject
							noPattern: false
							notifying: nil
							ifFail: nil.
						parser temporaries collect: [:temp | temp asString]
					] ifError: [{'<could not parse node>'}]
				].
			]
		).
]

{ #category : #'as yet unclassified' }
ComponentBrowser class >> getCurrentRoot [

	^ (((GRReact current instVarNamed: #sessions) associations first value) instVarNamed: #react) currentRoot.
]

{ #category : #'as yet unclassified' }
ComponentBrowser class >> openCurrent [

	^ self openForFiber: self getCurrentRoot.
]

{ #category : #'as yet unclassified' }
ComponentBrowser class >> openForFiber: aFiber [

	^ self new rootFiber: aFiber; build
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> build [

	| builder window |
	builder := ToolBuilder default.
	
	window := self buildWith: builder.
	builder open: window.
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> buildWith: builder [

	| windowSpec treeSpec listSpecTemps listSpecHooks listSpecProps |
	
	"Base window spec"
	windowSpec := builder pluggableWindowSpec new.
	windowSpec
		model: self;
		label: 'Component Browser';
		children: OrderedCollection new.
	
	"Top half: React scene tree"
	treeSpec := builder pluggableTreeSpec new.
	treeSpec
		model: self;
		getSelected: #currentSelection;
		setSelected: #currentSelection:;
		getChildren: #getChildrenOfFiber:;
		roots: #rootFiber;
		label: #getLabelOfFiber:;
		frame: (0@0 corner: 1@0.65).
	windowSpec children add: treeSpec.
	
	"Left list: temps (in Squeak)"
	listSpecTemps := builder pluggableListSpec new.
	listSpecTemps
		model: self;
		frame: (0@0.65 corner: 0.25@1);
		list: #getTempsOfCurrentSelection.
		
	windowSpec children add: listSpecTemps.
	
	"Middle list: hooks"
	listSpecHooks := builder pluggableListSpec new.
	listSpecHooks
		model: self;
		listItem: #getLabelOfState;
		frame: (0.25@0.65 corner: 0.6@1);
		list: #getHooksOfCurrentSelection.
		
	windowSpec children add: listSpecHooks.
	
	"Right list: props"
	listSpecProps := builder pluggableListSpec new.
	listSpecProps
		model: self;
		frame: (0.6@0.65 corner: 1@1);
		list: #getPropsOfCurrentSelection.
		
	windowSpec children add: listSpecProps.
	
	^ windowSpec
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> currentSelection [

	^ currentSelection
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> currentSelection: anItem [

	currentSelection := anItem.
	self changed: #currentSelection.
	self updateStateList.
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getChildrenOfFiber: aFiber [
	"Return a collection of children of an object."

	^ aFiber child ifNil: {} ifNotNil: [:child | self getSiblingsOfFiber: child]
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getHooksOfCurrentSelection [

	"Return the list of strings that should fill the data section."
	 ^ self currentSelection ifNil: #() ifNotNil: [:currentSelection | 
			self class displayHooksForFiber: currentSelection
		]
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getLabelOfFiber: aFiber [

	^ aFiber node asStringOrText
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getPropsOfCurrentSelection [

	"Return the list of props that should fill the data section."
	 ^ self currentSelection ifNil: #() ifNotNil: [:currentSelection | 
			self class displayPropsForFiber: currentSelection
		]
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getSiblingsOfFiber: aFiber [
	"Return a collection of aFiber and all of its siblings."

	^ {aFiber} , (aFiber sibling ifNil: {} ifNotNil: [:sibling | self getSiblingsOfFiber: sibling] )
	

]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getStateOfCurrentSelection [

	"Return the list of strings that should fill the data section."
	 ^ self currentSelection ifNil: #() ifNotNil: [:currentSelection | 
			self class displayStateForFiber: currentSelection
		]
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getTempsOfCurrentSelection [

	"Return the list of strings that should fill the props section."
	 ^ self currentSelection ifNil: #() ifNotNil: [:currentSelection | 
			self class displayTempsForFiber: currentSelection.
		]
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> rootFiber [

	^ { rootFiber }
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> rootFiber: aFiber [

	rootFiber := aFiber.
	
	"I changed my root fiber, therefore I need to tell me dependents that they need to re-request it with #rootFiber"
	self changed: #rootFiber.
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> updateStateList [

	self changed: #getTempsOfCurrentSelection.
	self changed: #getHooksOfCurrentSelection.
	self changed: #getPropsOfCurrentSelection.
]

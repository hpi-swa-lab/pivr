Class {
	#name : #ComponentBrowser,
	#superclass : #Model,
	#instVars : [
		'currentSelection',
		'rootFiber',
		'currentDataSelection'
	],
	#category : #'GReaSe-Tools'
}

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

	| windowSpec treeSpec listSpecLeft listSpecRight listSpecProps |
	
	"Base window spec"
	windowSpec := builder pluggableWindowSpec new.
	windowSpec
		model: self;
		label: 'Component Browser';
		children: OrderedCollection new.
	
	"Top half tree"
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
	
	"Bottom half: state"
	"Left"
	listSpecLeft := builder pluggableListSpec new.
	listSpecLeft
		model: self;
		frame: (0@0.65 corner: 0.25@1);
		list: #getStateOfCurrentSelection.
		
	windowSpec children add: listSpecLeft.
	
	"Right"
	listSpecRight := builder pluggableListSpec new.
	listSpecRight
		model: self;
		getSelected: #currentDataSelection;
		setSelected: #currentDataSelection:;
		listItem: #getLabelOfState;
		frame: (0.25@0.65 corner: 0.6@1);
		list: #getDataOfCurrentSelection.
		
	windowSpec children add: listSpecRight.
	
	listSpecProps := builder pluggableListSpec new.
	listSpecProps
		model: self;
		frame: (0.6@0.65 corner: 1@1);
		list: #getPropsOfCurrentSelection.
		
	windowSpec children add: listSpecProps.
	
	^ windowSpec
]

{ #category : #nil }
ComponentBrowser >> currentDataSelection [

	^ currentDataSelection
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> currentDataSelection: anItem [

	currentDataSelection := anItem.
	self changed: #currentDataSelection.
	
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
"Return a collection of children of an object. If empty, there are no children (so there wont be an arrow). We start by asking for a direct child. If child exists, we also need to ask it for its next sibling, then that sibling for it's siblings etc."

	^ aFiber child ifNil: {} ifNotNil: [:child | self getSiblingsOfFiber: child]
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getDataOfCurrentSelection [

	"Return the list of strings that should fill the data section."
	 ^ self currentSelection ifNil: #() ifNotNil: [:currentSelected | 
		currentSelected hooks
		]
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getLabelOfFiber: aFiber [

	^ aFiber node asStringOrText
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getPropsOfCurrentSelection [

	"Return the list of props that should fill the data section."
	 ^ self currentSelection ifNil: #() ifNotNil: [:currentSelected | 
		currentSelected node isGodotNode
			ifTrue: [currentSelected node properties associations]
			ifFalse: {'<>'}
		]
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getSiblingsOfFiber: aFiber [
"return a collection of aFiber and all of its siblings"

	^ {aFiber} , (aFiber sibling ifNil: {} ifNotNil: [:sibling | self getSiblingsOfFiber: sibling] )
	
"{aFiber} , {} -> {aFiber}"
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getStateOfCurrentSelection [

	| parser |

	"Return the list of strings that should fill the props section."
	 ^ self currentSelection ifNil: #() ifNotNil: [:currentSelection | 
		"Find out what currentSelection is. A GreASe-node or a Godot node?"
		self currentSelection node isGodotNode
			ifTrue: {'<is Godot>' }
			ifFalse: [
				(self currentSelection node isKindOf: CMFRootNode) ifTrue: {'<is root node>'} ifFalse: [
				parser := PPParser new
					parse: (self currentSelection node elementClass>>#render:) getSource
					class: UndefinedObject
					noPattern: false
					notifying: nil
					ifFail: nil.
				parser temporaries
				]
			]
		]
	"Plan: For Grease-stuff, we put hooks, for Godot-stuff we put subscribed callbacks"
	"Issue: State can have info, but no used name?"
	"Todo: What are the dependencies for memos about?"
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

	self changed: #getStateOfCurrentSelection.
	self changed: #getDataOfCurrentSelection.
	self changed: #getPropsOfCurrentSelection.
]

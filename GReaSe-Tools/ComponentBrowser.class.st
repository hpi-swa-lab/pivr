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

	| windowSpec treeSpec listSpecLeft |
	
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
	"Left - extract to own thing later"
	listSpecLeft := builder pluggableListSpec new.
	listSpecLeft
		model: self;
		frame: (0@0.65 corner: 0.5@1).
	windowSpec children add: listSpecLeft.
	
	
	^ windowSpec
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> currentSelection [

	^ currentSelection
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> currentSelection: anItem [

	currentSelection := anItem.
	self changed: #currentSelection
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getChildrenOfFiber: aFiber [
"Return a collection of children of an object. If empty, there are no children (so there wont be an arrow). We start by asking for a direct child. If child exists, we also need to ask it for its next sibling, then that sibling for it's siblings etc."

	^ aFiber child ifNil: {} ifNotNil: [:child | self getSiblingsOfFiber: child]
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getLabelOfFiber: aFiber [

	^ aFiber node asString
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> getSiblingsOfFiber: aFiber [
"return a collection of aFiber and all of its siblings"

	^ {aFiber} , (aFiber sibling ifNil: {} ifNotNil: [:sibling | self getSiblingsOfFiber: sibling] )
	
"{aFiber} , {} -> {aFiber}"
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

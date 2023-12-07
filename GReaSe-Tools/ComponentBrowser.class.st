Class {
	#name : #ComponentBrowser,
	#superclass : #Model,
	#category : #'GReaSe-Tools'
}

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
		model: self; "Why always model self?"
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
ComponentBrowser >> getList [
	"The Object explorer just returns the root value here. I don't really know why"
	
	^ {self root}
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> rootObject [

	^ self root value
]

{ #category : #'as yet unclassified' }
ComponentBrowser >> rootObject: aCMFReactWithFibers [

	self root value: aCMFReactWithFibers.
	
	"I think: Set up Tree view as a list component"
	self changed: #getList.
	"I think: Expand the current root"
	self changed: #expandRootsRequested.
	
	"I think: Select the first element in the List (that we fake as a tree) as a default object to not select something invalid"
	self currentSelection: self getList first.
]

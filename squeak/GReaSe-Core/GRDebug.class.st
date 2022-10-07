Class {
	#name : #GRDebug,
	#superclass : #Morph,
	#instVars : [
		'frameTime',
		'gcTime',
		'last'
	],
	#classVars : [
		'Current'
	],
	#category : #'GReaSe-Core-Debug'
}

{ #category : #'as yet unclassified' }
GRDebug class >> open [

	^ (Current := self new) openInWindow
]

{ #category : #'as yet unclassified' }
GRDebug class >> reportFrameTime: aBlock [

	Current ifNotNil: [:debug | debug reportFrameTime: aBlock timeToRun] ifNil: [aBlock value]
]

{ #category : #'as yet unclassified' }
GRDebug >> initialize [

	super initialize.
	
	self
		layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		addMorphBack: (frameTime := GRGraphPlot new label: 'Frame time');
		addMorphBack: (gcTime := GRGraphPlot new label: 'GC Time')
]

{ #category : #'as yet unclassified' }
GRDebug >> reportFrameTime: aNumber [

	frameTime reportValue: aNumber
]

{ #category : #'as yet unclassified' }
GRDebug >> step [

	| now |
	now := (Smalltalk vmParameterAt: 8) + (Smalltalk vmParameterAt: 10).
	last ifNotNil: [gcTime reportValue: now - last].
	last := now
]

{ #category : #'as yet unclassified' }
GRDebug >> stepTime [

	^ 0
]

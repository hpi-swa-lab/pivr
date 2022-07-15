Class {
	#name : #SBVREditor,
	#superclass : #SBEditor,
	#instVars : [
		'commandQueue',
		'godotProvider',
		'currentId',
		'vrIdToMorph'
	],
	#classVars : [
		'Instance'
	],
	#classInstVars : [
		'commandQueue'
	],
	#category : #'Sandblocks-TreeSitter-VR'
}

{ #category : #'as yet unclassified' }
SBVREditor class >> current [

	^ Instance := Instance ifNil: [self new openInWindow; yourself]
]

{ #category : #'as yet unclassified' }
SBVREditor >> do: aCommand [

	super do: aCommand.
	commandQueue add: aCommand
]

{ #category : #'as yet unclassified' }
SBVREditor >> getNextId [

	currentId := currentId + 1.
	^ currentId
]

{ #category : #'as yet unclassified' }
SBVREditor >> godotProvider [

	^ godotProvider
]

{ #category : #'as yet unclassified' }
SBVREditor >> godotProvider: anObject [

	godotProvider := anObject
]

{ #category : #'as yet unclassified' }
SBVREditor >> initialize [

	super initialize.
	
	currentId := 0.
	commandQueue := OrderedCollection new.
	
	vrIdToMorph := Dictionary new.
]

{ #category : #'as yet unclassified' }
SBVREditor >> morphAtVrId: vrId [

	^ vrIdToMorph at: vrId
]

{ #category : #'as yet unclassified' }
SBVREditor >> registerMorph: aMorph atVrId: aNumber [

	vrIdToMorph at: aNumber put: aMorph
]

{ #category : #'as yet unclassified' }
SBVREditor >> vrDoQueuedCommands [

	commandQueue do: [:command | command vrDo].
	commandQueue removeAll
]

{ #category : #'as yet unclassified' }
SBVREditor >> vrIds [

	^ vrIdToMorph keys
]

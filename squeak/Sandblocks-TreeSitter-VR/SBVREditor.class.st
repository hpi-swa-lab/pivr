Class {
	#name : #SBVREditor,
	#superclass : #SBEditor,
	#instVars : [
		'commandQueue',
		'godotProvider',
		'currentId',
		'vrIdToMorph',
		'tempInsertRegistry',
		'dirtyBlockIds',
		'insertPositionRegistry'
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

{ #category : #'insert commands' }
SBVREditor >> addDirtyBlockId: id [

	dirtyBlockIds add: id
]

{ #category : #'insert commands' }
SBVREditor >> batchedChangeStep: block [

	super batchedChangeStep: block.
	self dirtyAllBlocks
]

{ #category : #'insert commands' }
SBVREditor >> dirtyAllBlocks [

	self childSandblocksDo: [:block |
		self addDirtyBlockId: block vrId]
]

{ #category : #'action helpers' }
SBVREditor >> do: aCommand [

	super do: aCommand.
	commandQueue add: aCommand
]

{ #category : #'id mapping' }
SBVREditor >> getNextId [

	currentId := currentId + 1.
	^ currentId
]

{ #category : #accessing }
SBVREditor >> godotProvider [

	^ godotProvider
]

{ #category : #accessing }
SBVREditor >> godotProvider: anObject [

	godotProvider := anObject
]

{ #category : #initialization }
SBVREditor >> initialize [

	super initialize.
	
	currentId := 0.
	commandQueue := OrderedCollection new.
	dirtyBlockIds := Set new.
	
	vrIdToMorph := Dictionary new.
	insertPositionRegistry := Dictionary new.
]

{ #category : #'insert commands' }
SBVREditor >> insertCommandAtId: aNumber [

	^ tempInsertRegistry at: aNumber
]

{ #category : #initialization }
SBVREditor >> insertPositionWithId: id [

	^ insertPositionRegistry at: id
]

{ #category : #'insert commands' }
SBVREditor >> insertPositionsFor: aBlock [

	tempInsertRegistry := Dictionary new.
	^ (Array streamContents: [:stream |
		self cursorPositionsDo: [:pos |
			((pos block hasOwner: aBlock) or: [aBlock hasOwner: pos block] or: [aBlock = pos block]) ifFalse: [
				(pos isInsert and: [pos container isTSBlock]) ifTrue: [ | targetType id |
					targetType := pos command element.
					(aBlock adaptSlotFor: (SBTSSlot with: targetType) ifFailed: [nil]) ifNotNil: [:adaptedCopy |
						id := self getNextId.
						pos command morphs: {adaptedCopy}.
						tempInsertRegistry at: id put: pos command.
						stream nextPut: (Dictionary newFrom: {
							#id -> id.
							#depth -> pos container blockDepth.
							#bounds -> ((pos bounds translateBy: pos container containingFloat position negated) in: [:r | {r left. r top. r width. r height}]).
							#floatId -> pos container containingFloat vrId})]].
				(pos isSelect and: [pos block isUnknown]) ifTrue: [ | id |
					id := self getNextId.
					tempInsertRegistry at: id put: (SBReplaceCommand new target: pos block replacer: aBlock copyBlock).
					stream nextPut: (Dictionary newFrom: {
						#id -> id.
						#depth -> pos block blockDepth.
						#bounds -> ((pos block bounds translateBy: pos block containingFloat position negated) in: [:r | {r left. r top. r width. r height}]).
						#floatId -> pos block containingFloat vrId})]]]]) asJsonString
]

{ #category : #'id mapping' }
SBVREditor >> morphAtVrId: vrId [

	^ vrIdToMorph at: vrId
]

{ #category : #'insert commands' }
SBVREditor >> refreshAllInsertPositions [

	insertPositionRegistry removeAll.
	
	^ Array streamContents: [:stream |
		self cursorPositionsDo: [:pos |
			(pos isInsert and: [pos container ~~ self]) ifTrue: [ | id |
				id := self getNextId.
				insertPositionRegistry at: id put: pos.
				
				stream nextPut: (Dictionary newFrom: {
					#id -> id.
					#parentBlockId -> pos container vrId.
					#bounds -> ((pos bounds "translateBy: pos container containingFloat position") in: [:r | {r left. r top. r width. r height}]).
				})]]].
]

{ #category : #'id mapping' }
SBVREditor >> registerMorph: aMorph atVrId: aNumber [

	vrIdToMorph at: aNumber put: aMorph
]

{ #category : #'insert commands' }
SBVREditor >> showInsertPositionsFor: aBlock [

	self godotProvider showInsertPositions: (self insertPositionsFor: aBlock)
]

{ #category : #'action helpers' }
SBVREditor >> syncAllLayouts [

	| structures |
	structures := Array streamContents: [:stream |
		self childSandblocksDo: [:block |
			stream nextPut: block exportStructure]].
	self godotProvider syncMultipleLayouts: structures asJsonString.
]

{ #category : #'action helpers' }
SBVREditor >> vrDoQueuedCommands [

	commandQueue ifNotEmpty: [
		commandQueue do: [:command | command vrDo].
		commandQueue removeAll].
	dirtyBlockIds ifNotEmpty: [
		self godotProvider syncMultipleLayouts:
			(dirtyBlockIds collect: [:id | (self morphAtVrId: id) exportStructure]) asJsonString.
		dirtyBlockIds removeAll]
]

{ #category : #'id mapping' }
SBVREditor >> vrIds [

	^ vrIdToMorph keys
]

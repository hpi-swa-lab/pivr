Class {
	#name : #GRObjectId,
	#superclass : #Object,
	#instVars : [
		'objectId'
	],
	#category : #'GReaSe-Core'
}

{ #category : #comparing }
GRObjectId >> = anObject [

	^ self class = anObject class and: [anObject objectId = self objectId]
]

{ #category : #converting }
GRObjectId >> grAsClass: aSymbol [

	^ (Smalltalk classNamed: aSymbol) basicNew objectId: self objectId
]

{ #category : #converting }
GRObjectId >> grEqual: anObject [

	^ self = anObject
]

{ #category : #comparing }
GRObjectId >> hash [

	^ objectId hash
]

{ #category : #accessing }
GRObjectId >> objectId [

	^ objectId
]

{ #category : #accessing }
GRObjectId >> objectId: aNumber [

	objectId := aNumber
]

{ #category : #printing }
GRObjectId >> printOn: aStream [

	aStream nextPutAll: self className.
	aStream nextPut: $(.
	aStream nextPutAll: self objectId asString.
	aStream nextPut: $)
]

{ #category : #converting }
GRObjectId >> putVariantOn: aWriteStream [

	aWriteStream nextLittleEndianNumber: 4 put: (17 bitOr: (1 bitShift: 16)).
	aWriteStream nextLittleEndianNumber: 8 put: objectId
]

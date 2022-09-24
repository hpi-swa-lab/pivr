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

{ #category : #converting }
GRObjectId >> putVariantOn: aWriteStream [

	aWriteStream nextLittleEndianNumber: 4 put: (17 bitOr: (1 bitShift: 16)).
	aWriteStream nextLittleEndianNumber: 8 put: objectId
]

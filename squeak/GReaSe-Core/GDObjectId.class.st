Class {
	#name : #GDObjectId,
	#superclass : #Object,
	#instVars : [
		'objectId'
	],
	#category : #'GReaSe-Core'
}

{ #category : #comparing }
GDObjectId >> = anObject [

	^ self class = anObject class and: [anObject objectId = self objectId]
]

{ #category : #comparing }
GDObjectId >> hash [

	^ objectId hash
]

{ #category : #accessing }
GDObjectId >> objectId [

	^ objectId
]

{ #category : #accessing }
GDObjectId >> objectId: aNumber [

	objectId := aNumber
]

{ #category : #converting }
GDObjectId >> putVariantOn: aWriteStream [

	aWriteStream nextLittleEndianNumber: 4 put: (17 bitOr: (1 bitShift: 16)).
	aWriteStream nextLittleEndianNumber: 8 put: objectId
]

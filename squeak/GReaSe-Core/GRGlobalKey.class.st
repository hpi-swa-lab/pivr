Class {
	#name : #GRGlobalKey,
	#superclass : #Object,
	#instVars : [
		'tag'
	],
	#category : #'GReaSe-Core'
}

{ #category : #comparing }
GRGlobalKey >> = aKey [

	^ self class = aKey class and: [self tag = aKey tag]
]

{ #category : #comparing }
GRGlobalKey >> hash [

	^ tag hash
]

{ #category : #accessing }
GRGlobalKey >> tag [

	^ tag
]

{ #category : #accessing }
GRGlobalKey >> tag: aSymbol [

	tag := aSymbol
]

Class {
	#name : #GDApiReader,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #'instance creation' }
GDApiReader class >> forFile: aPath [

	^ self forStream: (FileStream readOnlyFileNamed: aPath)
]

{ #category : #'instance creation' }
GDApiReader class >> forStream: aStream [

	^ self new stream: aStream
]

{ #category : #reading }
GDApiReader >> read [
	"Returns one sequence of GDClassSpecs that can be generated in order
	and a collection of GDMethodSpecs that can be generated afterwards."
	
	self subclassResponsibility
]

{ #category : #accessing }
GDApiReader >> stream: aStream [

	stream := aStream
]

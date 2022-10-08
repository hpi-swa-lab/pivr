Class {
	#name : #GRTestSocketSession,
	#superclass : #GRSocketSession,
	#category : #'GReaSe-Test'
}

{ #category : #'as yet unclassified' }
GRTestSocketSession >> handleError: anError [
	"instead of spawning a new process and a debugger, just signal so it's easier for the test"

	anError signal
]

{ #category : #'as yet unclassified' }
GRTestSocketSession >> readRefs [
	"don't do anything, not relevant to the test and would have to be mocked on binary packet level"

	
]

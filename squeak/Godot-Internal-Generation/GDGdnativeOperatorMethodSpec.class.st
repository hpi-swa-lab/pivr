Class {
	#name : #GDGdnativeOperatorMethodSpec,
	#superclass : #GDGdnativeMethodSpec,
	#instVars : [
		'otherMethodName'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #'as yet unclassified' }
GDGdnativeOperatorMethodSpec >> argumentName [

	^ self arguments first argumentParamterName
]

{ #category : #'as yet unclassified' }
GDGdnativeOperatorMethodSpec >> otherMethodName [

	^ otherMethodName
]

{ #category : #'as yet unclassified' }
GDGdnativeOperatorMethodSpec >> otherMethodName: aString [

	otherMethodName := aString
]

{ #category : #'as yet unclassified' }
GDGdnativeOperatorMethodSpec >> source [

	^ '{1} arg
	<generated>
	
	^ arg {3}: self' format: {self nameString. self argumentName. self otherMethodName}
]

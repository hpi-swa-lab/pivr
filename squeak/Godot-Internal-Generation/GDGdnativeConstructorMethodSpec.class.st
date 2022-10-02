Class {
	#name : #GDGdnativeConstructorMethodSpec,
	#superclass : #GDGdnativeInstanceMethodSpec,
	#category : #'Godot-Internal-Generation'
}

{ #category : #'as yet unclassified' }
GDGdnativeConstructorMethodSpec >> fullApiName [

	^ super fullApiName, (arguments ifEmpty: [':'] ifNotEmpty: ['with:'])
]

{ #category : #'as yet unclassified' }
GDGdnativeConstructorMethodSpec >> isClassMethod [

	^ true
]

{ #category : #'as yet unclassified' }
GDGdnativeConstructorMethodSpec >> source [
	
	^ '{1}{2}
	<generated>
	
	| instance |
	instance := self allocateExternal.
	GDApi instance perform: #{3} withArguments: \{instance. {4}\}.
	^ instance' format: {self nameString. self methodArgumentString. self fullApiName. self argumentArrayString}
]

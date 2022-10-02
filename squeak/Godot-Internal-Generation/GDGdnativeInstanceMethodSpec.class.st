Class {
	#name : #GDGdnativeInstanceMethodSpec,
	#superclass : #GDGdnativeMethodSpec,
	#instVars : [
		'returnsVariant'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #'as yet unclassified' }
GDGdnativeInstanceMethodSpec >> argumentArrayString [
	
	^ (arguments collect: [:arg | | parameterName conversionCall |
			parameterName := arg argumentParamterName.
			conversionCall := arg typeIsGDVariant
				ifTrue: ['asGDVariant']
				ifFalse: [
					arg typeIsGDString
						ifTrue: ['asGDString']
						ifFalse: ['']].
			parameterName, ' ', conversionCall]) joinSeparatedBy: '. '
]

{ #category : #'as yet unclassified' }
GDGdnativeInstanceMethodSpec >> methodArgumentString [

	| firstArg methodArguments |
	methodArguments := arguments.
	(methodArguments notEmpty and: [methodArguments first isSelf]) ifTrue:
		[methodArguments := methodArguments allButFirst].
	
	methodArguments isEmpty ifTrue: [^ ''].
	
	firstArg := methodArguments first methodArgumentString capitalized.
	(self nameString asLowercase endsWith: (firstArg copyUpTo: $:) asLowercase) ifTrue: [
		firstArg := ':', (firstArg copyAfter: $:)].
	
	^ ({firstArg}, (methodArguments allButFirst collect: #methodArgumentString)) joinSeparatedBy: ' '
]

{ #category : #'as yet unclassified' }
GDGdnativeInstanceMethodSpec >> nameString [

	^ name
]

{ #category : #'as yet unclassified' }
GDGdnativeInstanceMethodSpec >> optionalUnwrapString [

	^ self returnsVariant
		ifTrue: ['unwrap']
		ifFalse: ['']
]

{ #category : #'as yet unclassified' }
GDGdnativeInstanceMethodSpec >> returnsVariant [

	^ returnsVariant
]

{ #category : #'as yet unclassified' }
GDGdnativeInstanceMethodSpec >> returnsVariant: aBoolean [

	returnsVariant := aBoolean
]

{ #category : #'as yet unclassified' }
GDGdnativeInstanceMethodSpec >> source [
	
	"TODO: lots of code duplication with GDGodotApiMethodSpec"
	^ '{1}{2}
	<generated>
	
	^ (GDApi instance perform: #{3} withArguments: \{{4}\}) {5}' format: {
		self nameString.
		self methodArgumentString.
		self fullApiName.
		self argumentArrayString.
		self optionalUnwrapString
	}
]

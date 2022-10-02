Class {
	#name : #GDGdnativeApiReader,
	#superclass : #GDApiReader,
	#classVars : [
		'ObjectCategories'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #'as yet unclassified' }
GDGdnativeApiReader >> read [

	| specs apiSpec |
	apiSpec := (Json readFrom: stream) core.
	specs := OrderedCollection new.
	
	[apiSpec] whileNotNil: [
		specs add: (apiSpec api collect: [:methodJsonObject |
			GDGdnativeMethodSpec allFromAPIJsonObject: methodJsonObject]).
		apiSpec := apiSpec next].
	
	^ {{}. specs flatten}
]

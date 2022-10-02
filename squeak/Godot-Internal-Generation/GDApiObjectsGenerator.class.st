Class {
	#name : #GDApiObjectsGenerator,
	#superclass : #Object,
	#instVars : [
		'stream',
		'topLevel',
		'dependants',
		'progress',
		'progressStep',
		'objectSpecsByName',
		'apiReader'
	],
	#classVars : [
		'ObjectCategories'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #names }
GDApiObjectsGenerator class >> classPrefix [

	^ 'GD'
]

{ #category : #using }
GDApiObjectsGenerator class >> deleteGdnativeFunctions [

	{GDGdnativeMethodSpec methodCategory.
	GDGdnativeMethodSpec propertyCategory.
	GDGdnativeMethodSpec operatorCategory.
	GDGdnativeMethodSpec constructorCategory.
	GDGdnativeMethodSpec privateCategory} do: [:category |
		(Smalltalk environment organization listAtCategoryNamed: #'Godot-Builtins')
			do: [:className | | builtinClass |
				builtinClass := (Smalltalk classNamed: className).
				builtinClass removeCategory: category.
				builtinClass class removeCategory: category]].
		
	Smalltalk allClasses do: [:class |
		class removeCategory: GDGdnativeMethodSpec extensionCategory]
]

{ #category : #using }
GDApiObjectsGenerator class >> deleteGodotApi [

	Smalltalk environment organization removeCategoriesMatching: (self fullCategoryName: '*').
	GDApi class removeCategory: GDGodotApiSingletonListMethodSpec methodCategory.
]

{ #category : #'instance creation' }
GDApiObjectsGenerator class >> forGodotApiJson: aJsonStream [

	^ self new apiReader: (GDGodotApiReader forStream: aJsonStream)
]

{ #category : #names }
GDApiObjectsGenerator class >> fullCategoryName: aString [

	^ 'Godot-API-', aString
]

{ #category : #using }
GDApiObjectsGenerator class >> generate [

	GDApiObjectsGenerator generateGodotApi: (WebClient httpGet: 'https://raw.githubusercontent.com/godotengine/godot-headers/3.5/api.json') content readStream
]

{ #category : #using }
GDApiObjectsGenerator class >> generateGdnativeApi: aJsonStream [

	(self new apiReader: (GDGdnativeApiReader forStream: aJsonStream)) generate
]

{ #category : #using }
GDApiObjectsGenerator class >> generateGdnativeApiForFile: aPath [

	(self new apiReader: (GDGdnativeApiReader forStream: (FileStream readOnlyFileNamed: aPath))) generate
]

{ #category : #using }
GDApiObjectsGenerator class >> generateGodotApi: aJsonStream [

	(self forGodotApiJson: aJsonStream) generate
]

{ #category : #using }
GDApiObjectsGenerator class >> generateGodotApiFromFile: aPath [

	self generateGodotApi: (FileStream readOnlyFileNamed: aPath)
]

{ #category : #names }
GDApiObjectsGenerator class >> squeakClassName: aString [

	^ self classPrefix, aString
]

{ #category : #names }
GDApiObjectsGenerator class >> squeakIdentifierName: aString [

	| parts |
	parts := aString subStrings: '_'.
	^ parts first, ((parts collect: #capitalized from: 2 to: parts size) join)
]

{ #category : #accessing }
GDApiObjectsGenerator >> apiReader: anApiReader [

	apiReader := anApiReader
]

{ #category : #generating }
GDApiObjectsGenerator >> generate [

	| specs |
	specs := apiReader read.

	specs first
		do: #generate
		displayingProgress: [:classSpec | 'Generating {1}...' format: {classSpec name}].
	specs second
		do: #generate
		displayingProgress: [:methodSpec | 'Generating {1}>>{2}...' format: {methodSpec className. methodSpec name}].
	"| objectSpecs |
	objectSpecs := Json readFrom: stream.
	
	self withProgressSteps: objectSpecs size do: [
		objectSpecsByName := (objectSpecs collect: [:spec | (spec at: #name) asSymbol -> spec]) asDictionary.
	
		self determineDependencies: objectSpecs.
		topLevel do: [:spec | self generateObjectTree: spec inCategory: GDApiObjectsGenerator baseCategory]]"
]

{ #category : #accessing }
GDApiObjectsGenerator >> stream: aStream [

	stream := aStream
]

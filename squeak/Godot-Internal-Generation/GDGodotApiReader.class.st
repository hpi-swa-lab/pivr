Class {
	#name : #GDGodotApiReader,
	#superclass : #GDApiReader,
	#classVars : [
		'ObjectCategories'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #sorting }
GDGodotApiReader class >> initialize [

	" GDGodotApiReader initialize "

	super initialize.

	ObjectCategories := Dictionary withAll: ({
		'GlobalConstants' -> 'Core'.
		'Object' -> 'Core'.
		'Node' -> 'Node'.
		'Node2D' -> '2D'.
		'Shape2D' -> '2D'.
		'Spatial' -> 'Spatial'.
		'Shape' -> 'Shape'.
		'Control' -> 'Control'.
		'VisualScriptNode' -> 'VisualScript'.
		'VisualShaderNode' -> 'VisualShader'.
		'Animation' -> 'Animation'.
		'AnimationNode' -> 'Animation'.
		'AudioBusLayout' -> 'Audio'.
		'AudioEffect' -> 'Audio'.
		'AudioStream' -> 'Audio'.
		'InputEvent' -> 'InputEvent'.
		'Mesh' -> 'Mesh'.
		'MeshLibrary' -> 'Mesh'.
		'Material' -> 'Material'.
		'Texture' -> 'Texture'.
		'TextureLayered' -> 'Texture'.
	} do: [:association |
		association key: (GDApiObjectsGenerator squeakClassName: association key) asSymbol.
		association value: (GDApiObjectsGenerator fullCategoryName: association value)])
]

{ #category : #sorting }
GDGodotApiReader class >> sortAndCategorizeClassSpecs: aClassSpecsSequence [

	| dependencyInfo topLevel specsByName |
	topLevel := OrderedCollection new.
	dependencyInfo := Dictionary new.
	specsByName := Dictionary withAll: (aClassSpecsSequence collect: [:spec | spec name -> spec]).
	
	aClassSpecsSequence do: [:spec |
		spec parentName = GDClassSpec rootClassName
			ifTrue: [
				topLevel add: spec]
			ifFalse: [
				(dependencyInfo at: (specsByName at: spec parentName) ifAbsentPut: [OrderedCollection new]) add: spec]].
	
	^ (topLevel collect: [:topSpec | self sortedAndCategorizedDependencySequenceFor: topSpec dependencyInfo: dependencyInfo]) flatten
]

{ #category : #sorting }
GDGodotApiReader class >> sortedAndCategorizedDependencySequenceFor: classSpec categorized: category dependencyInfo: dependencyInfo [

	classSpec category: (ObjectCategories at: classSpec name ifAbsent: [category]).
	
	^ {classSpec. (dependencyInfo at: classSpec ifAbsent: [{}]) collect: [:childClassSpec |
			self sortedAndCategorizedDependencySequenceFor: childClassSpec
				categorized: classSpec category
				dependencyInfo: dependencyInfo]}
]

{ #category : #sorting }
GDGodotApiReader class >> sortedAndCategorizedDependencySequenceFor: classSpec dependencyInfo: dependencyInfo [

	^ self sortedAndCategorizedDependencySequenceFor: classSpec
		categorized: (GDApiObjectsGenerator fullCategoryName: 'Uncategorized')
		dependencyInfo: dependencyInfo
]

{ #category : #reading }
GDGodotApiReader >> read [

	| contents classSpecs methodSpecs singletonClassSpecs |
	contents := Json readFrom: stream.
	
	classSpecs := OrderedCollection new.
	singletonClassSpecs := OrderedCollection new.
	methodSpecs := OrderedCollection new.
	
	contents do: [:classJsonObject | | classSpec |
		classSpec := classSpecs add: (GDClassSpec fromApiJsonObject: classJsonObject).
		classSpec isSingleton ifTrue: [singletonClassSpecs add: classSpec].
		
		methodSpecs addAll: (classJsonObject methods
			select: [:methodJsonObject | (methodJsonObject name beginsWith: '_') not and: [classJsonObject properties noneSatisfy: [:property | property setter = methodJsonObject name or: [property getter = methodJsonObject name]]]]
			thenCollect: [:methodJsonObject | GDGodotApiMethodSpec allFromApiJsonObject: methodJsonObject forClass: classSpec name]).
		
		methodSpecs addAll: (classJsonObject properties
			select: [:propertyJsonObject | (propertyJsonObject name beginsWith: '_') not]
			thenCollect: [:propertyJsonObject | | propertyMethods |
				propertyMethods := OrderedCollection new.
				(propertyJsonObject name includes: $/) ifFalse: [
					propertyJsonObject getter notEmpty ifTrue: [
						propertyMethods add: (GDGodotApiPropertyGetterSpec
							fromAPIJsonObject: propertyJsonObject
							className: classSpec name)].
					propertyJsonObject setter notEmpty ifTrue: [
						propertyMethods add: (GDGodotApiPropertySetterSpec
							fromAPIJsonObject: propertyJsonObject
							className: classSpec name)]].
				propertyMethods]).
		
		methodSpecs addAll: (classJsonObject signals collect: [:signal | GDGodotApiSignalSpec fromAPIJsonObject: signal className: classSpec name]).
		
		classJsonObject constants keysAndValuesDo: [:name :value | methodSpecs add: (GDGodotApiConstantSpec fromKey: name value: value className: classSpec name)]].
	
	^ {
		self class sortAndCategorizeClassSpecs: classSpecs.
		{methodSpecs. GDGodotApiSingletonListMethodSpec newFromClassSpecs: singletonClassSpecs} flatten}
]

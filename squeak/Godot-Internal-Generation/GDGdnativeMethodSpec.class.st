Class {
	#name : #GDGdnativeMethodSpec,
	#superclass : #GDMethodSpec,
	#instVars : [
		'apiName'
	],
	#classVars : [
		'BuiltinClassNames',
		'CToSqueakNames'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #'instance creation' }
GDGdnativeMethodSpec class >> allFromAPIJsonObject: aJsonObject [

	| classAssociation methodName |
	classAssociation := self associationForCType: aJsonObject name.
	(classAssociation isNil or: [(BuiltinClassNames includes: classAssociation value) not])
		ifTrue: [^ #()].

	methodName := self nameFor: aJsonObject name withoutPrefix: classAssociation key.
	
	(methodName beginsWith: 'new') ifTrue: [
		^ self newConstructor: aJsonObject name: methodName classAssociation: classAssociation].
	
	^ self newInstanceMethods: aJsonObject name: methodName classAssociation: classAssociation
		
]

{ #category : #'instance creation' }
GDGdnativeMethodSpec class >> apiNameFromJsonObject: aJsonObject [

	"TODO: this name is defined by GDApi>>generateGDNativeApi. refactoring necessary"
	^ ((aJsonObject name subStrings: '_')
		allButFirst collect: #capitalized)
		join withFirstCharacterDownshifted
]

{ #category : #'as yet unclassified' }
GDGdnativeMethodSpec class >> associationForCType: aString [

	CToSqueakNames associationsDo: [:association |
		(aString beginsWith: association key) ifTrue: [^ association]].
	^ nil
]

{ #category : #constants }
GDGdnativeMethodSpec class >> constructorCategory [

	^ '*autogenerated - constructor'
]

{ #category : #constants }
GDGdnativeMethodSpec class >> extensionCategory [

	^ '*Godot-Builtins - autogenerated private'
]

{ #category : #'class initialization' }
GDGdnativeMethodSpec class >> initialize [

	| squeakClassNames |
	super initialize.
	
	BuiltinClassNames := {
		'GDAABB'.
		'GDArray'.
		'GDBasis'.
		'GDBool'.
		'GDColor'.
		'GDDictionary'.
		'GDInt'.
		'GDNodePath'.
		'GDObject'.
		'GDPlane'.
		'GDPoolByteArray'.
		'GDPoolColorArray'.
		'GDPoolIntArray'.
		'GDPoolRealArray'.
		'GDPoolStringArray'.
		'GDPoolVector2Array'.
		'GDPoolVector3Array'.
		'GDQuat'.
		'GDReal'.
		'GDRect2'.
		'GDRid'.
		'GDTransform2D'.
		'GDTransform'.
		'GDVector2'.
		'GDVector3'
	}.
	
	squeakClassNames := BuiltinClassNames asOrderedCollection addAll: {
		'GDVariant'
	}; yourself.
	
	CToSqueakNames := squeakClassNames collect: [:class |
		'godot_', (((class allButFirst: 2) piecesCutWhere: [:left :right |
			(left isLowercase or: left isDigit) and: (right isUppercase and: right ~= $D)])
			joinSeparatedBy: '_')
			asLowercase -> class].
		
	"TODO: dirty fix"
	(CToSqueakNames at: (CToSqueakNames findFirst: [:assoc | assoc key = 'godot_int'])) value: 'Integer'.
	(CToSqueakNames at: (CToSqueakNames findFirst: [:assoc | assoc key = 'godot_real'])) value: 'Float'.
	(CToSqueakNames at: (CToSqueakNames findFirst: [:assoc | assoc key = 'godot_bool'])) value: 'Boolean'.
]

{ #category : #constants }
GDGdnativeMethodSpec class >> methodCategory [

	^ '*autogenerated - methods'
]

{ #category : #'as yet unclassified' }
GDGdnativeMethodSpec class >> nameFor: aCMethodName withoutPrefix: aPrefix [

	| parts |
	parts := ((aCMethodName copyReplaceAll: aPrefix with: '') splitBy: '_') select: #notEmpty.
	^ parts first, ((parts allButFirst collect: #capitalized) join)
]

{ #category : #'instance creation' }
GDGdnativeMethodSpec class >> newConstructor: aJsonObject name: methodName classAssociation: classAssociation [

	| apiName arguments |
	arguments := aJsonObject arguments allButFirst withIndexCollect: [:argTuple :index |
		GDArgumentSpec fromCJsonTuple: argTuple position: index].
	apiName := self apiNameFromJsonObject: aJsonObject.
	
	^ (GDGdnativeConstructorMethodSpec
		newNamed: methodName
		arguments: arguments
		category: self constructorCategory
		className: classAssociation value)
		apiName: apiName
]

{ #category : #'instance creation' }
GDGdnativeMethodSpec class >> newInstanceMethodNamed: methodName arguments: arguments category: category className: className apiName: apiName returnsVariant: returnsVariant [

	^ (self newNamed: methodName
		arguments: arguments
		category: category
		className: className)
		apiName: apiName;
		returnsVariant: returnsVariant
]

{ #category : #'instance creation' }
GDGdnativeMethodSpec class >> newInstanceMethods: aJsonObject name: name classAssociation: classAssociation [
	
	| methodName specs arguments apiName returnsVariant |
	"TODO: consider automatically converting GDStrings to Strings instead"
	methodName := name = 'asString' ifTrue: ['asGDString'] ifFalse: [name].
	arguments := aJsonObject arguments withIndexCollect: [:argTuple :index |
		GDArgumentSpec fromCJsonTuple: argTuple position: index].
	apiName := self apiNameFromJsonObject: aJsonObject.
	returnsVariant := aJsonObject return_type beginsWith: 'godot_variant'.

	specs := OrderedCollection with: (
		GDGdnativeInstanceMethodSpec newInstanceMethodNamed: methodName
			arguments: arguments
			category: self methodCategory
			className: classAssociation value
			apiName: apiName
			returnsVariant: returnsVariant).
	
	(#(get set) anySatisfy: [:prefix | methodName beginsWith: prefix]) ifTrue: [specs add: (
		GDGdnativeInstanceMethodSpec newInstanceMethodNamed: (methodName allButFirst: 3) withFirstCharacterDownshifted
			arguments: arguments
			category: self propertyCategory
			className: classAssociation value
			apiName: apiName
			returnsVariant: returnsVariant)].
	
	(methodName beginsWith: 'operator') ifTrue: [specs addAll: (
		self newInstanceOperatorNamed: (methodName allButFirst: 8) withFirstCharacterDownshifted
		arguments: arguments
		className: classAssociation value
		apiName: apiName)].
	
	^ specs
]

{ #category : #'instance creation' }
GDGdnativeMethodSpec class >> newInstanceOperatorNamed: methodName arguments: arguments className: className apiName: apiName [

	| otherClass operatorSymbols operatorSymbol otherCategory operatorName otherMethodName |
	
	operatorSymbols := Dictionary withAll: {
		'equal' -> '='.
		'less' -> '<'.
		'add' -> '+'.
		'plus' -> '+'.
		'subtract' -> '-'.
		'multiply' -> '*'.
		'divide' -> '/'.
	}.
	
	operatorName := (methodName piecesCutWhere: [:a :b | a isLowercase and: b isUppercase]) first.
	operatorSymbol := operatorSymbols at: operatorName ifAbsent: [
		Transcript showln: 'Operator for ', methodName, ' nyi'.
		^ #()].
	otherClass := (self associationForCType: arguments second type) value.
	otherCategory := (Smalltalk classNamed: otherClass) category = 'Godot-Builtins'
		ifTrue: [self privateCategory]
		ifFalse: [self extensionCategory].
	otherMethodName := operatorName, className.
	
	^ {
		GDGdnativeInstanceMethodSpec newInstanceMethodNamed: otherMethodName
		arguments: {(arguments first copy isSelf: false) name: ''. arguments second copy isSelf: true}
		category: otherCategory
		className: otherClass
		apiName: apiName
		returnsVariant: false "TODO: the proper way would be to look at the return type".
		
		(GDGdnativeOperatorMethodSpec
			newNamed: operatorSymbol
			arguments: {arguments second}
			category: self operatorCategory
			className: className)
			otherMethodName: otherMethodName
	}
]

{ #category : #constants }
GDGdnativeMethodSpec class >> operatorCategory [

	^ '*autogenerated - operators'
]

{ #category : #constants }
GDGdnativeMethodSpec class >> privateCategory [

	^ '*autogenerated - private'
]

{ #category : #constants }
GDGdnativeMethodSpec class >> propertyCategory [

	^ '*autogenerated - properties'
]

{ #category : #'as yet unclassified' }
GDGdnativeMethodSpec >> apiName [

	^ apiName
]

{ #category : #'as yet unclassified' }
GDGdnativeMethodSpec >> apiName: aString [

	apiName := aString
]

{ #category : #'as yet unclassified' }
GDGdnativeMethodSpec >> fullApiName [

	arguments
		ifEmpty: [^ apiName]
		"TODO: is there a better way to repeat a string x times?"
		ifNotEmpty: [^ apiName, ':', ((OrderedCollection new add: 'with:' withOccurrences: arguments size - 1; yourself) join)]
]

{ #category : #'as yet unclassified' }
GDGdnativeMethodSpec >> nameString [

	^ name
]

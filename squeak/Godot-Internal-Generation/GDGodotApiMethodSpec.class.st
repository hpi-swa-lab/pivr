Class {
	#name : #GDGodotApiMethodSpec,
	#superclass : #GDMethodSpec,
	#category : #'Godot-Internal-Generation'
}

{ #category : #'instance creation' }
GDGodotApiMethodSpec class >> allFromApiJsonObject: aJsonObject forClass: className [

	| specs arguments methodName |
	specs := OrderedCollection new.
	methodName := aJsonObject name.
	arguments := (aJsonObject arguments withIndexCollect: [:arg :index | GDArgumentSpec fromApiJsonObject: arg position: index]) asOrderedCollection.
	
	aJsonObject has_varargs ifTrue: [arguments add: GDArgumentSpec newVararg].
	
	[arguments notEmpty and: [arguments last hasDefaultValue or: [arguments last isVararg]]] whileTrue: [
		specs add: ((self newNamed: methodName arguments: arguments copy category: self methodCategory className: className) returnType: aJsonObject return_type).
		arguments removeLast].
	
	^ specs
		add: ((self newNamed: methodName arguments: arguments category: self methodCategory className: className) returnType: aJsonObject return_type);
		yourself
]

{ #category : #constants }
GDGodotApiMethodSpec class >> methodCategory [

	^ '*autogenerated - methods'
]

{ #category : #generating }
GDGodotApiMethodSpec >> argumentArrayString [

	(arguments notEmpty and: [arguments last isVararg])
		ifTrue: [^ '\{\{{1}\}. {2}\} concatenation' format: {
			(arguments allButLast collect: #argumentParamterName) joinSeparatedBy: '. '.
			arguments last argumentParamterName}]
		ifFalse: [^ '\{{1}\}' format: {(arguments collect: #argumentParamterName) joinSeparatedBy: '. '}]
	
]

{ #category : #generating }
GDGodotApiMethodSpec >> methodArgumentString [

	| firstArg |
	arguments isEmpty ifTrue: [^ ''].
	
	firstArg := arguments first methodArgumentString capitalized.
	(self nameString endsWith: (firstArg copyUpTo: $:)) ifTrue: [
		firstArg := ':', (firstArg copyAfter: $:)].
	
	^ ({firstArg}, (arguments allButFirst collect: #methodArgumentString)) joinSeparatedBy: ' '
]

{ #category : #generating }
GDGodotApiMethodSpec >> nameString [

	^ self class squeakifyMethodName: name
]

{ #category : #generating }
GDGodotApiMethodSpec >> source [

	^ '{1}{2}
	<generated>
	
	^ self callOnVariant: ''{3}'' with: {4} return: {5}' format: {
		self nameString.
		self methodArgumentString.
		name.
		self argumentArrayString.
		(GDApiObjectsGenerator squeakClassName: self returnType) asSymbol storeString}
]
Class {
	#name : #GDArgumentSpec,
	#superclass : #Object,
	#instVars : [
		'type',
		'name',
		'hasDefaultValue',
		'suffix',
		'isVararg',
		'isSelf'
	],
	#category : #'Godot-Internal-Generation'
}

{ #category : #'instance creation' }
GDArgumentSpec class >> fromApiJsonObject: aJsonObject position: aNumber [

	^ self new
		name: aJsonObject name;
		type: aJsonObject type;
		hasDefaultValue: aJsonObject has_default_value;
		suffix: aNumber asString
]

{ #category : #'instance creation' }
GDArgumentSpec class >> fromApiPropertiesJsonObject: aJsonObject [

	^ self new
		name: '';
		type: (aJsonObject type copyReplaceAll: ',' with: 'Or') asLegalSelector;
		suffix: '1'
]

{ #category : #'instance creation' }
GDArgumentSpec class >> fromCJsonTuple: aTuple position: aNumber [

	| argName argType |
	argName := (aTuple second copyAfter: $_).
	argType := ((aTuple first findTokens) reject: [:string | string = 'const' or: string = '*']) first.

	^ self new
		name: argName;
		type: argType;
		suffix: aNumber asString;
		isSelf: (argName includesSubstring: 'self')
	
]

{ #category : #'instance creation' }
GDArgumentSpec class >> newVararg [

	^ self new
		name: 'withArguments';
		type: 'sequence';
		isVararg: true;
		suffix: 'vararg'
]

{ #category : #accessing }
GDArgumentSpec >> argumentMethodName [

	^ (self removeUnderscores: name) withFirstCharacterDownshifted
]

{ #category : #accessing }
GDArgumentSpec >> argumentParamterName [

	| fixedType prefix |
	self isSelf ifTrue: [^ 'self'].
	
	fixedType := ((self removeUnderscores: type) capitalized).
	prefix := 'a', (fixedType first isVowel ifTrue: ['n'] ifFalse: ['']).
	^ prefix, fixedType, '_', suffix
]

{ #category : #accessing }
GDArgumentSpec >> hasDefaultValue [

	^ hasDefaultValue
]

{ #category : #accessing }
GDArgumentSpec >> hasDefaultValue: aBoolean [

	hasDefaultValue := aBoolean
]

{ #category : #initialization }
GDArgumentSpec >> initialize [

	self hasDefaultValue: false.
	self isVararg: false.
	self isSelf: false.
]

{ #category : #accessing }
GDArgumentSpec >> isSelf [

	^ isSelf
]

{ #category : #accessing }
GDArgumentSpec >> isSelf: aBoolean [

	isSelf := aBoolean
]

{ #category : #accessing }
GDArgumentSpec >> isVararg [

	^ isVararg
]

{ #category : #accessing }
GDArgumentSpec >> isVararg: aBoolean [

	isVararg := aBoolean
]

{ #category : #accessing }
GDArgumentSpec >> methodArgumentString [

	^ self isSelf
		ifTrue: ['']
		ifFalse:['{1}: {2}' format: {self argumentMethodName. self argumentParamterName}]
]

{ #category : #accessing }
GDArgumentSpec >> name [

	^ name
]

{ #category : #accessing }
GDArgumentSpec >> name: aString [

	name := aString
]

{ #category : #private }
GDArgumentSpec >> removeUnderscores: aString [

	| parts |
	parts := aString splitBy: '_'.
	^ parts size = 1
		ifTrue: [aString]
		ifFalse: [{parts first withFirstCharacterDownshifted. parts allButFirst collect: #capitalized} flatten join].
]

{ #category : #accessing }
GDArgumentSpec >> suffix: aString [

	suffix := aString
]

{ #category : #accessing }
GDArgumentSpec >> type [

	^ type
]

{ #category : #accessing }
GDArgumentSpec >> type: aString [

	type := aString
]

{ #category : #accessing }
GDArgumentSpec >> typeIsGDString [

	^ type = 'godot_string'
]

{ #category : #accessing }
GDArgumentSpec >> typeIsGDVariant [

	^ type = 'godot_variant'
]

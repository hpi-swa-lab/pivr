Extension { #name : #CMFReactNodeComponent }

{ #category : #'*GreaSe-Core-override' }
CMFReactNodeComponent >> doesNotUnderstand: aMessage [

	| key |
	key := aMessage selector.
	(key precedence = 3 and: [(key indexOf: $:) = key size]) ifTrue: [ | value prop |
		prop := key allButLast asSymbol.
		value := aMessage arguments first.
		value isGodotNode ifTrue: [
			value isResource: true.
			value godotId: prop].
		props ifNil: [props := Dictionary new].
		props at: prop put: value.
		^ self].
	^ super doesNotUnderstand: aMessage

]

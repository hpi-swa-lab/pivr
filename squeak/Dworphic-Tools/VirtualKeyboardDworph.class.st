Class {
	#name : #VirtualKeyboardDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Tools'
}

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph class >> appDescription [
	<home>

	^ super appDescription
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> collisionShape [

	^ (self godot: #BoxShape) extents: 0.02 @ 0.005 @ 0.03
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> keySize [

	^ 0.05
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> layout: aBool [

	^ {
	aBool ifFalse: {'1'. '2'. '3'. '4'. '5'. '6'. '7'. '8'. '9'. '0'} ifTrue: {'!'. '"'. '§'. '$'. '%'. '&'. '/'. '('. ')'. '='}.
				{'Q'. 'W'. 'E'. 'R'. 'T'. 'Z'. 'U'. 'I'. 'O'. 'P'}.
				{'A'. 'S'. 'D'. 'F'. 'G'. 'H'. 'J'. 'K'. 'L'}.
	aBool ifFalse: {'Shift'. 'Y'. 'X'. 'C'. 'V'. 'B'. 'N'. 'M'. 'Comma'. 'Period'. 'Minus'} ifTrue: {'Shift'. 'Y'. 'X'. 'C'. 'V'. 'B'. 'N'. 'M'. 'Semicolon'. 'Colon'. 'Underscore'}.
				{'Braceleft'. 'Bracketleft'. 'Space'. 'Bracketright'. 'Braceright'. 'Plus'. 'Asterisk'. 'Numbersign'. 'Apostrophe'}}
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> render: props [

	| focus |
	focus := (self useProvided: #textFocus) get.
	
	^ focus notNone ifTrue: [
		(self methodAsComponent: #renderKeyboard:)
			transform: (focus textAreaBottomCenter localTranslatedBy: 0 @ -20 cm @ 5 cm);
			onTextEntered: focus textEnteredCallback]
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> renderKey: props [

	| hovered |
	hovered := self useState: false.
	
	^ GRInteractiveArea new
		touch: true;
		point: true;
		onButtonPress: [:e | e isTrigger ifTrue: [(props at: #onPressed) value]];
		onHover: [hovered set: true];
		onBlur: [hovered set: false];
		children: {
			self cubeOfSize: self keySize asPoint @ 0.02 color: (hovered get
				ifTrue: [Color r: 0.669 g: 0.669 b: 0.669]
				ifFalse: [Color r: 0.37 g: 0.37 b: 0.37]).
			GDLabel3D new
				translation: 0 @ 0 @ 0.011;
				text: (props at: #letter) asString;
				pixelSize: 0.001.
			GDCollisionShape new shape: (GDBoxShape new extents: self keySize asPoint / 2 @ 0.01)};
		translation: (props at: #position) @ 0 * self keySize
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> renderKeyboard: props [

	| layout shiftPressed |
	shiftPressed := self useState: false.
	layout := self layout: shiftPressed get.
	
	^ GRGrabbableArea new
		transform: (props at: #transform);
		children: {
			(self
				cubeOfSize: (layout collect: #size) max * self keySize @ (layout size * self keySize) @ 0.01
				color: (Color r: 0.37 g: 0.37 b: 0.37)) children: {
				GDSpatial new
					translation: (layout collect: #size) max - 1 * self keySize / -2 @ (self keySize / -2 * (layout size + 1)) @ 0;
					children: (layout withIndexCollect: [:row :rowIndex |
						row asOrderedCollection withIndexCollect: [:letter :columnIndex | | keyCode |
							keyCode := GDGlobalConstants perform: ('key{1}' format: {letter}) asSymbol.
							(self methodAsComponent: #renderKey:)
								key: letter;
								letter: (self scancodeName: keyCode);
								position: columnIndex - 1 @ (layout size - (rowIndex - 1));
								onPressed: [
									keyCode = GDGlobalConstants keyShift
										ifTrue: [shiftPressed set: shiftPressed not]
										ifFalse: [
											(props at: #onTextEntered) get value: letter.
											shiftPressed set: false]]]])}}
]

{ #category : #'as yet unclassified' }
VirtualKeyboardDworph >> scancodeName: aScancode [
	"This should work using
		(GD_OS instance) getScancodeStringCode: (aScancode)
	but right now it doesn't, so we're doing the conversion manually."

	^ aScancode caseOf: {
			[GDGlobalConstants keyShift] -> ['Shift'].
			[GDGlobalConstants keyComma] -> [','].
			[GDGlobalConstants keyPeriod] -> ['.'].
			[GDGlobalConstants keyMinus] -> ['-'].
			[GDGlobalConstants keySemicolon] -> [';'].
			[GDGlobalConstants keyColon] -> [':'].
			[GDGlobalConstants keyUnderscore] -> ['_'].
			[GDGlobalConstants keyBraceleft] -> ['{'].
			[GDGlobalConstants keyBracketleft] -> ['['].
			[GDGlobalConstants keySpace] -> [' '].
			[GDGlobalConstants keyBracketright] -> [']'].
			[GDGlobalConstants keyBraceright] -> ['}'].
		} otherwise: [
			(Character value: aScancode) asString]
]

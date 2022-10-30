Class {
	#name : #ButtonDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
ButtonDworph >> render: props [

	^ props extract: [:onPress :color :rest | | hovered |
		hovered := self useState: false.
		GRInteractiveArea new
			props: rest;
			point: true;
			translation: 0.02 @ 0 @ 0;
			onHover: [hovered set: true];
			onBlur: [hovered set: false];
			onButtonPress: [:event | event isTrigger ifTrue: [onPress value]];
			children: {self cubeOfSize: 0.02 color: (hovered get ifTrue: [color muchLighter] ifFalse: [color])}]
]

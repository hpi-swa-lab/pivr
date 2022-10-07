Class {
	#name : #GRGraphPlot,
	#superclass : #Morph,
	#instVars : [
		'data',
		'label',
		'labelColor'
	],
	#category : #'GReaSe-Core-Debug'
}

{ #category : #'as yet unclassified' }
GRGraphPlot >> drawOn: aCanvas [

	| max x height |
	max := data max max: 1.
	x := 0.
	height := self height - 1.
	data do: [:value | | nowY |
		nowY := (value / max * self height) ceiling.
		aCanvas
			fillRectangle: (x - self gap @ (height - nowY + 1) + self position extent: self gap @ nowY)
			color: (Color r: 1 g: 0.0 b: 0.0).
		x := x + self gap].
	aCanvas
		drawString: label, ' (', data last asString, '/', max asString, ')'
		at: self position
		font: nil
		color: labelColor
]

{ #category : #'as yet unclassified' }
GRGraphPlot >> extent: aPoint [

	super extent: aPoint.
	data size ~= aPoint x ifTrue: [data size: aPoint x // self gap]
]

{ #category : #'as yet unclassified' }
GRGraphPlot >> gap [

	^ 1
]

{ #category : #'as yet unclassified' }
GRGraphPlot >> initialize [

	super initialize.
	data := GRCyclicList new.
	label := ''.
	labelColor := Color r: 0.0 g: 0.0 b: 0.0.
	self
		hResizing: #spaceFill;
		vResizing: #rigid;
		height: TextStyle defaultFont height * 2
]

{ #category : #'as yet unclassified' }
GRGraphPlot >> label [

	^ label
]

{ #category : #'as yet unclassified' }
GRGraphPlot >> label: aString [

	label := aString
]

{ #category : #'as yet unclassified' }
GRGraphPlot >> labelColor: aColor [

	labelColor := aColor
]

{ #category : #'as yet unclassified' }
GRGraphPlot >> reportValue: aNumber [

	data add: aNumber.
	self changed
]

Class {
	#name : #GREvents,
	#superclass : #GDBaseObject,
	#category : #'GReaSe-React'
}

{ #category : #'as yet unclassified' }
GREvents >> godotClass [

	^ #GREvents
]

{ #category : #'as yet unclassified' }
GREvents >> onButton: aBlock [
	"pressed: boolean, button: number, position: Vector2"

	properties at: #button put: aBlock
]

{ #category : #'as yet unclassified' }
GREvents >> onEvent: anEvent [
	"the raw GDEvent objects"

	properties at: #event put: anEvent
]

{ #category : #'as yet unclassified' }
GREvents >> onKeyboard: aBlock [
	"pressed: boolean, scanCode: GDGlobalConstants key*, key: unicode integer"

	properties at: #keyboard put: aBlock
]

{ #category : #'as yet unclassified' }
GREvents >> subscribeToMousePosition: aBlock [

	self subscribeTo: #'mouse_position' do: aBlock
]

{ #category : #'as yet unclassified' }
GREvents >> subscribeToRelativeMouseMotion: aBlock [

	self subscribeTo: #'relative_mouse_motion' do: aBlock
]

Class {
	#name : #GRExternalEvents,
	#superclass : #GDBaseObject,
	#category : #'GReaSe-Components'
}

{ #category : #'as yet unclassified' }
GRExternalEvents >> godotClass [

	^ #GREvents
]

{ #category : #'as yet unclassified' }
GRExternalEvents >> onButton: aBlock [
	"pressed: boolean, button: number, position: Vector2"

	properties at: #button put: aBlock
]

{ #category : #'as yet unclassified' }
GRExternalEvents >> onEvent: anEvent [
	"the raw GDEvent objects"

	properties at: #event put: anEvent
]

{ #category : #'as yet unclassified' }
GRExternalEvents >> onKeyboard: aBlock [
	"pressed: boolean, scanCode: GDGlobalConstants key*, key: unicode integer"

	properties at: #keyboard put: aBlock
]

{ #category : #'as yet unclassified' }
GRExternalEvents >> subscribeToMousePosition: aBlock [

	self subscribeTo: #'mouse_position' do: aBlock
]

{ #category : #'as yet unclassified' }
GRExternalEvents >> subscribeToRelativeMouseMotion: aBlock [

	self subscribeTo: #'relative_mouse_motion' do: aBlock
]

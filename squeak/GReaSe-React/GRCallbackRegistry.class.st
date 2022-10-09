Class {
	#name : #GRCallbackRegistry,
	#superclass : #Object,
	#instVars : [
		'callbacks'
	],
	#category : #'GReaSe-React'
}

{ #category : #'as yet unclassified' }
GRCallbackRegistry >> clean [

	callbacks keysAndValuesRemove: [:key :value | value isNil]
]

{ #category : #'as yet unclassified' }
GRCallbackRegistry >> get: anId [

	^ callbacks at: anId
]

{ #category : #'as yet unclassified' }
GRCallbackRegistry >> idFor: aClosure [

	^ callbacks keyAtValue: aClosure
]

{ #category : #'as yet unclassified' }
GRCallbackRegistry >> initialize [

	callbacks := (GRReact useFibers ifTrue: [WeakValueDictionary] ifFalse: ["without fibers, we tend to have some leaks that then lead to crashes"
	Dictionary]) new
]

{ #category : #'as yet unclassified' }
GRCallbackRegistry >> registerCallback: aClosure [

	| id |
	callbacks keysAndValuesDo: [:closureId :closure | closure == aClosure ifTrue: [^ closureId]].
	id := GRReact nextGodotId.
	callbacks at: id put: aClosure.
	^ id
]

{ #category : #'as yet unclassified' }
GRCallbackRegistry >> replace: anIdNumber with: aBlock [

	callbacks at: anIdNumber put: aBlock
]

{ #category : #'as yet unclassified' }
GRCallbackRegistry >> size [

	^ callbacks size
]

Class {
	#name : #GDSocketSession,
	#superclass : #Object,
	#instVars : [
		'react',
		'sessionId',
		'stream'
	],
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GDSocketSession >> bindRefs: aCollection [

	react waitingRefs with: aCollection do: [:ref :obj | ref set: obj]
]

{ #category : #'as yet unclassified' }
GDSocketSession >> callOn: anObject method: aString arguments: aCollection [

	| response |
	GDSocketListener
		putVariant: {GDSocketListener messageTypeCallFromSqueak. anObject. aString. aCollection}
		on: stream.
	
	response := GDSocketListener readMessageFrom: stream.
	self assert: response first = GDSocketListener messageTypeResponseToCallFromGodot.
	self assert: response second = sessionId.
	^ response third
]

{ #category : #'as yet unclassified' }
GDSocketSession >> close [

	stream close
]

{ #category : #'as yet unclassified' }
GDSocketSession >> get: aString of: anObject [

	| response |
	GDSocketListener
		putVariant: {GDSocketListener messageTypePropertyGetFromSqueak. anObject. aString}
		on: stream.
	
	response := GDSocketListener readMessageFrom: stream.
	self assert: response first = GDSocketListener messageTypeResponseToCallFromGodot.
	self assert: response second = sessionId.
	^ response third
]

{ #category : #'as yet unclassified' }
GDSocketSession >> reactComponent: aComponentClass [

	react := GRReact new session: self.
	react initAndRender: aComponentClass asReactNodeBuilder build
]

{ #category : #'as yet unclassified' }
GDSocketSession >> sessionId [

	^ sessionId ifNil: [sessionId := GRReact nextGodotId]
]

{ #category : #'as yet unclassified' }
GDSocketSession >> set: aString of: anObject to: aValueObject [

	| response |
	GDSocketListener
		putVariant: {GDSocketListener messageTypePropertySetFromSqueak. anObject. aString. aValueObject}
		on: stream.
	
	response := GDSocketListener readMessageFrom: stream.
	self assert: response first = GDSocketListener messageTypeResponseToCallFromGodot.
	self assert: response second = sessionId.
	^ response third
]

{ #category : #'as yet unclassified' }
GDSocketSession >> socketStream: aStream [

	stream := aStream
]

{ #category : #'as yet unclassified' }
GDSocketSession >> tick: aCollection [

	^ react tick: aCollection
]

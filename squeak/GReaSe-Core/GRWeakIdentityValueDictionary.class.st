Class {
	#name : #GRWeakIdentityValueDictionary,
	#superclass : #WeakValueDictionary,
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRWeakIdentityValueDictionary >> keyAtValue: value ifAbsent: exceptionBlock [
 
	self associationsDo: 
		[:association | value == association value ifTrue: [^association key]].
	^exceptionBlock value
]

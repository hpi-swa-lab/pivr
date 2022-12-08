Class {
	#name : #CodeBlockLayoutParamters,
	#superclass : #Object,
	#instVars : [
		'blockDepth',
		'morphicScale',
		'rootGlobalTransform',
		'rootGlobalExtent'
	],
	#category : #'Dworphic-BlockCode'
}

{ #category : #'as yet unclassified' }
CodeBlockLayoutParamters >> blockDepth [

	^ blockDepth
]

{ #category : #'as yet unclassified' }
CodeBlockLayoutParamters >> blockDepth: aNumber [

	blockDepth := aNumber
]

{ #category : #'as yet unclassified' }
CodeBlockLayoutParamters >> morphicScale [

	^ morphicScale
]

{ #category : #'as yet unclassified' }
CodeBlockLayoutParamters >> morphicScale: aNumber [

	morphicScale := aNumber
]

{ #category : #'as yet unclassified' }
CodeBlockLayoutParamters >> rootGlobalExtent [
	
	^ rootGlobalExtent
]

{ #category : #'as yet unclassified' }
CodeBlockLayoutParamters >> rootGlobalExtent: aPoint [
	
	rootGlobalExtent := aPoint
]

{ #category : #'as yet unclassified' }
CodeBlockLayoutParamters >> rootGlobalTransform [
	
	^ rootGlobalTransform
]

{ #category : #'as yet unclassified' }
CodeBlockLayoutParamters >> rootGlobalTransform: aMatrix4x4 [
	
	rootGlobalTransform := aMatrix4x4
]

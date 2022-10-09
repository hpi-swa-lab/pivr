Class {
	#name : #GRSReactiveComponent,
	#superclass : #GRComponent,
	#category : #'GReaSe-Signals'
}

{ #category : #'as yet unclassified' }
GRSReactiveComponent >> createEffect: aBlock [

	^ self useMemo: [GRSEffect do: aBlock] dependencies: {}
]

{ #category : #'as yet unclassified' }
GRSReactiveComponent >> createSignal: anObject [

	^ self useMemo: [GRSDataNode with: anObject] dependencies: {}
]

{ #category : #'as yet unclassified' }
GRSReactiveComponent >> useRender: aBlock [

	| forceUpdate update |
	forceUpdate := self useState: 0.
	
	update := self createEffect: [
		forceUpdate set: [:c | c + 1].
		aBlock value].
	
	^ update value
]

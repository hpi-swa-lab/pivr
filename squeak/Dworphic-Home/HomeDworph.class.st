Class {
	#name : #HomeDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Home'
}

{ #category : #'as yet unclassified' }
HomeDworph >> render: props [

	^ WorldDworph new children: {
		[ | openApplication once |
			openApplication := self useProvided: #openApplication.
			once := self useRef: true.
			self
				useEffect: [
					"effects are re-executed on hot reload"
					once get ifTrue: [
						once set: false.
						(GRReact autoStartApplications splitBy: ',') do: [:className | openApplication value: (Smalltalk classNamed: className asSymbol) appDescription]]]
				dependencies: {}.
			nil] asComponent}
]

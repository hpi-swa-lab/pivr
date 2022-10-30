Class {
	#name : #HomeDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Home'
}

{ #category : #'as yet unclassified' }
HomeDworph >> render: props [

	^ WorldDworph new children: {
		[ | openApplication |
			openApplication := self useProvided: #openApplication.
			self
				useEffect: [(GRReact autoStartApplications splitBy: ',') do: [:className | openApplication value: (Smalltalk classNamed: className asSymbol) appDescription]]
				dependencies: {}.
			nil] asComponent}
]

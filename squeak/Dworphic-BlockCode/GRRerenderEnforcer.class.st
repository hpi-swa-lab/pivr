Class {
	#name : #GRRerenderEnforcer,
	#superclass : #GRComponent,
	#category : #'Dworphic-BlockCode'
}

{ #category : #'as yet unclassified' }
GRRerenderEnforcer >> render: props [

	| n |
	n := self useState: 0.

	^ GDTimer new
		autostart: true;
		subscribeTo: #time_left do: [:t | n set: [:old | old + 1]]
]

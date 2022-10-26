Class {
	#name : #AppBarDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
AppBarDworph >> render: props [

	| apps closeApplication |
	apps := self useProvided: #applications.
	closeApplication := self useProvided: #closeApplication.
	^ apps withIndexCollect: [:app :index |
		GDSpatial new
			translation: 0 @ (index * -0.15) @ 0;
			children: {
				GDLabel3D new
					horizontalAlignment: GDGlobalConstants halignRight;
					text: app name.
				GRInteractiveArea new
					translation: 0.1 @ 0 @ 0;
					onButtonPress: [:event | event isTrigger ifTrue: [closeApplication value: app id]];
					children: {self cubeOfSize: 0.1 color: Color red}}]
]

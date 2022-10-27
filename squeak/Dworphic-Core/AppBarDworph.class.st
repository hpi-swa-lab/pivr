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
	^ {
		GDLabel3D new
			translation: 0.2 @ 0 @ 0;
			horizontalAlignment: GDGlobalConstants halignRight;
			text: 'Running Apps'}, (apps withIndexCollect: [:app :index |
		GDSpatial new
			translation: 0 @ (index * -0.15) @ 0;
			children: {
				GDLabel3D new
					horizontalAlignment: GDGlobalConstants halignRight;
					text: app name.
				GRInteractiveArea new
					translation: 0.1 @ 0 @ 0;
					onButtonPress: [:event | event isTrigger ifTrue: [closeApplication value: app id]];
					children: {self cubeOfSize: 0.1 color: (Color r: 1 g: 0.0 b: 0.0)}}])
]

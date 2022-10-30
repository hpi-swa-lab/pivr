Class {
	#name : #AppBarDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Home'
}

{ #category : #'as yet unclassified' }
AppBarDworph >> render: props [

	| apps closeApplication |
	apps := self useProvided: #applications.
	closeApplication := self useProvided: #closeApplication.
	^ {
		GDLabel3D new
			translation: 0.03 @ 0.02 @ 0;
			pixelSize: 0.002;
			horizontalAlignment: GDGlobalConstants halignRight;
			text: 'Running Apps'}, (apps withIndexCollect: [:app :index |
		GDSpatial new
			translation: 0 @ (index * -0.03) @ 0;
			children: {
				GDLabel3D new
					horizontalAlignment: GDGlobalConstants halignRight;
					pixelSize: 0.002;
					text: app name.
				GRInteractiveArea new
					translation: 0.02 @ 0 @ 0;
					onButtonPress: [:event | event isTrigger ifTrue: [closeApplication value: app]];
					children: {self cubeOfSize: 0.02 color: (Color r: 1 g: 0.0 b: 0.0)}}])
]

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
	
	self useVoiceIntents: (apps withIndexCollect: [:app :index |
			'close ', index -> [closeApplication value: app]
		]) key: 'applications'.
	
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
				ButtonDworph new
					onPress: [closeApplication value: app];
					translation: 0.02 @ 0 @ 0;
					color: Color red}])
]

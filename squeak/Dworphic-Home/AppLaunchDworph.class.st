Class {
	#name : #AppLaunchDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Home'
}

{ #category : #'as yet unclassified' }
AppLaunchDworph >> render: props [

	| apps openApplication |
	apps := Array streamContents: [:stream | GRComponent allSubclassesDo: [:cls | (Pragma allNamed: #home in: cls class) ifNotEmpty: [stream nextPut: cls appDescription]]].
	
	openApplication := self useProvided: #openApplication.
	
	self useVoiceIntent: 'open application' do: [self halt].
	
	^ {
		GDLabel3D new
			translation: 0.03 @ 0.02 @ 0;
			pixelSize: 0.002;
			horizontalAlignment: GDGlobalConstants halignRight;
			text: 'Launcher'}, (apps withIndexCollect: [:app :index |
		{
			[self useVoiceIntent: 'open ', index asString do: [openApplication value: app copy]. nil] asComponent.
			GDSpatial new
				translation: 0 @ (index * -0.03) @ 0;
				children: {
					GDLabel3D new
						horizontalAlignment: GDGlobalConstants halignRight;
						pixelSize: 0.002;
						text: app name.
					ButtonDworph new
						onPress: [openApplication value: app copy];
						translation: 0.02 @ 0 @ 0;
						color: Color green}}])
]

Class {
	#name : #AppLaunchDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
AppLaunchDworph >> render: props [

	| apps openApplication |
	apps := self
		useMemo: [{#CubeApp. #VirtualKeyboardDworph} collect: [:app | (Smalltalk classNamed: app) appDescription]]
		dependencies: {}.
	
	openApplication := self useProvided: #openApplication.
	
	^ {
		GDLabel3D new
			translation: 0.2 @ 0 @ 0;
			horizontalAlignment: GDGlobalConstants halignRight;
			text: 'Launcher'}, (apps withIndexCollect: [:app :index |
		GDSpatial new
			translation: 0 @ (index * -0.15) @ 0;
			children: {
				GDLabel3D new
					horizontalAlignment: GDGlobalConstants halignRight;
					text: app name.
				GRInteractiveArea new
					translation: 0.1 @ 0 @ 0;
					onButtonPress: [:event | event isTrigger ifTrue: [openApplication value: app]];
					children: {self cubeOfSize: 0.1 color: (Color r: 0.0 g: 1 b: 0.0)}}])
]

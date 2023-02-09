Class {
	#name : #AppControl,
	#superclass : #GRComponent,
	#category : #'Dworphic-Home'
}

{ #category : #'as yet unclassified' }
AppControl class >> appDescription [
	<home>

	^ super appDescription
]

{ #category : #'as yet unclassified' }
AppControl >> render: props [

	| shown transform head |
	shown := self useState: true.
	transform := self useState: (Matrix4x4 withOffset: 0 @ 1.2 @ -1.2).
	head := self useProvidedRef: #headTransform.
	
	self useVoiceIntents: {
		'show' -> [
		shown set: true.
		transform set: (head get localTranslatedBy: 0 @ 0 @ -0.5)].
		'hide' -> [
		shown set: false.
		transform set: (head get localTranslatedBy: 0 @ 0 @ -0.5)]
	} key: 'apps'.

	self
		useButtonPress: [:e |
			e button = GDGlobalConstants joyOculusAx ifTrue: [ | newTransform at from |
				shown set: [:o | o not].
				at := head get translation.
				from := ((head get orientation transform: 0 @ 0 @ -1) y: 0) normalize + at.
				newTransform := (Matrix4x4 lookAt: at from: from up: 0 @ 1 @ 0) addRotationAroundY: 180.
				transform set: newTransform]]
		release: [:e | ]
		axisChange: [:e | ]
		side: #right.
	
	^ shown get ifTrue: [
		GDSpatial new
			transform: transform get;
			children: {
				GDSpatial new
					children: AppBarDworph new;
					translation: -0.2 @ 0 @ 0.
				GDSpatial new
					children: AppLaunchDworph new;
					translation: 0.2 @ 0 @ 0.
				GDLabel3D new
					translation: -0.05 @ 0.06 @ 0;
					pixelSize: 0.001;
					horizontalAlignment: GDGlobalConstants halignCenter;
					text: 'Press (A) to toggle.'}]
]

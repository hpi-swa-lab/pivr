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
	
	self useVoiceIntent: 'toggle apps' do: [
		shown set: [:o | o not].
		transform set: (head get localTranslatedBy: 0 @ 0 @ -0.5)].
	
	self
		useButtonPress: [:e |
			e button = GDGlobalConstants joyOculusAx ifTrue: [
				shown set: [:o | o not].
				transform set: (head get localTranslatedBy: 0 @ 0 @ -0.5)]]
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

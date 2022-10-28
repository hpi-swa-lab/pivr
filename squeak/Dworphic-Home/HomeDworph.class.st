Class {
	#name : #HomeDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Home'
}

{ #category : #'as yet unclassified' }
HomeDworph >> render: props [

	^ WorldDworph new children: {
		GDSpatial new
			children: AppBarDworph new;
			translation: 2 @ 1.5 @ 1.
		[
			self
				useApplication: [
					DworphicApplicationDescription new
						name: 'Launcher';
						render: [
							GDSpatial new
								children: AppLaunchDworph new;
								translation: 1 @ 1.5 @ 1]]
				dependencies: {}.
			nil] asComponent}
]

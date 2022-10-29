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
			translation: 1 @ 1.2 @ -1.2.
		[
			self
				useApplication: [
					DworphicApplicationDescription new
						name: 'Launcher';
						render: [
							GDSpatial new
								children: AppLaunchDworph new;
								translation: 0 @ 1.2 @ -1.2]]
				dependencies: {}.
			nil] asComponent}
]

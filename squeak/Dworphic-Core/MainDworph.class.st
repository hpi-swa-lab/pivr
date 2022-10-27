Class {
	#name : #MainDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
MainDworph >> render: props [

	^ AlternativeWorldDworph new children: {
		Avatar new.
		GDSpatial new
			children: AppLaunchDworph new;
			translation: 1 @ 1.5 @ 1.
		GDSpatial new
			children: AppBarDworph new;
			translation: 2 @ 1.5 @ 1}
]

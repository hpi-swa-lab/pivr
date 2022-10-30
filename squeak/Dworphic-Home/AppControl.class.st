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

	^ {
		GDSpatial new
			children: AppBarDworph new;
			translation: 1 @ 1.2 @ -1.2.
		GDSpatial new
			children: AppLaunchDworph new;
			translation: 0 @ 1.2 @ -1.2}
]

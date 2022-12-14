Class {
	#name : #DworphicPointerTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #failures }
DworphicPointerTest >> expectedFailures [

	^ #(#testHover)
]

{ #category : #'as yet unclassified' }
DworphicPointerTest >> testHover [

	| hovered |
	hovered := false.
	self openComponent: [
		WorldDworph new children: {
			GRPointer new side: #left.
			GRInteractiveArea new
				onHover: [hovered := true];
				children: {
					GDCollisionShape new
						shape: GDBoxShape new;
						name: 'shape'.
					GDSpatial new}}].
	self tick: {
		(godotTree firstNodeNamed: 'shape') parent
			signal: #'area_entered'
			with: {GRObjectId new objectId: (godotTree firstNodeOfType: #Area) path}}.
	self assert: hovered
]

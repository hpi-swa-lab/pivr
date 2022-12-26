Class {
	#name : #GRAnimation,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components'
}

{ #category : #'as yet unclassified' }
GRAnimation >> render: props [

	^ props extract: [:object :value :property :duration :transition :ease | | tween |
		tween := self useGodotRef.
		self useEffect: [tween get start] dependencies: {value. property. object ifNotNil: #objectId}.
		GDTween new
			ref: tween;
			call: #'interpolate_property' arguments: {
				object.
				property.
				nil.
				value.
				duration ifNil: [0.3].
				transition ifNil: [GDTween transCubic].
				ease ifNil: [GDTween easeInOut]}]
]

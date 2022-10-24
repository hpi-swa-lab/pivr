Class {
	#name : #GRPointer,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
GRPointer >> render: props [

	| length activeEventHandlers addHandAreaHandlers areaRef createInteractiveEvent removeHandAreaHandlers |
	length := props at: #length ifAbsent: [10].
	
	createInteractiveEvent := [
		GRInteractiveAreaEvent new
			controllerRef: nil;
			side: (props at: #side);
			transform: Matrix4x4 identity].
	areaRef := self useGodotRef.
	activeEventHandlers := self useState: OrderedCollection new.
	addHandAreaHandlers := self useProvided: #addHandAreaHandlers.
	removeHandAreaHandlers := self useProvided: #removeHandAreaHandlers.
	self
		useEffect: [
			addHandAreaHandlers value: areaRef get value: (Dictionary withAll: {
				#onAreaEntered -> [:eventHandlers |
					"Transcript showln: 'interactable entered hand'."
					(eventHandlers at: #onHover) get ifNotNil: [:block |
						block cull: createInteractiveEvent value].
					activeEventHandlers set: [:old | old copyWith: eventHandlers]].
				#onAreaExited -> [:eventHandlers |
					"Transcript showln: 'interactable exited hand'."
					(eventHandlers at: #onBlur) get ifNotNil: [:block |
						block cull: createInteractiveEvent value].
					activeEventHandlers set: [:old | old copyWithout: eventHandlers]]}).
			[removeHandAreaHandlers value: areaRef get]]
		dependencies: #().

	^ GDArea new
		ref: areaRef;
		children: {
			GDCollisionShape new
				shape: (GDRayShape new
					length: length).
			GDMeshInstance new
				rotation: Float pi / 2 @ 0 @ 0;
				translation: 0 @ 0 @ length / 2;
				mesh: (GDCylinderMesh new
					bottomRadius: 0.01;
					topRadius: 0.01;
					height: length;
					material: (GDSpatialMaterial new
						albedoColor: (Color red alpha: 0.5);
						flagsTransparent: true))}
]

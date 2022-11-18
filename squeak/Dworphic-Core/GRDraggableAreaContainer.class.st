"
This component must be used to contain draggable areas whose releaseCondition is #containerUnmount. Draggable areas will release their locks on grabbed hands when this container unmounts.

It is not necessary to contain draggable areas with the releaseCondition #selfUnmount within this component.
"
Class {
	#name : #GRDraggableAreaContainer,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #rendering }
GRDraggableAreaContainer >> render: props [

	| handles releaseHandLock |
	releaseHandLock := self useProvided: #releaseHandLock.
	handles := self useRef: OrderedCollection new.
	self useEffect: [
		 [handles do: [:handle | releaseHandLock value: handle]]]
		dependencies: #().

	^ GRProvider values: {
			#registerHandleInContainer -> [:handle |
				self assert: (handles get includes: handle) not
					description: ('Handle {1} registered twice in container' format: {handle}).
				handles add: handle]}
		children: {
			GDSpatial new
				setAll: props;
				children: #children}
]

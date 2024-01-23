Class {
	#name : #GRViewportTexture,
	#superclass : #GRComponent,
	#category : #'GReaSe-React'
}

{ #category : #'as yet unclassified' }
GRViewportTexture >> render: props [

	^ props extract: [:extent :children :meshDo :getViewport | | viewportTex viewport |
		viewportTex := self useState: nil.
		viewport := self useGodotRef.
		self useEffect: [
				getViewport ifNotNil: [getViewport cull: viewport]]
			dependencies: {viewport get ifNotNil: #objectId}.
		
		 {
			GDViewport new
				ref: viewport;
				size: extent;
				renderTargetVFlip: true;
				renderTargetUpdateMode: GDViewport updateAlways;
				subscribeCall: 'get_texture' with: #() do: [:tex | viewportTex set: tex];
				children: children.
			meshDo value: (GDSpatialMaterial new
				flagsUnshaded: true;
				flagsAlbedoTexForceSrgb: true;
				albedoTexture: viewportTex get;
				resourceLocalToScene: true)}]
]

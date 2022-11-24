Class {
	#name : #GRViewportTexture,
	#superclass : #GRComponent,
	#category : #'GReaSe-React'
}

{ #category : #'as yet unclassified' }
GRViewportTexture >> render: props [

	^ props extract: [:extent :children :meshDo | | viewportTex |
		viewportTex := self useState: nil.
		{
			GDViewport new
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

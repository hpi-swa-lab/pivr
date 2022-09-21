Class {
	#name : #SBTSBlock3D,
	#superclass : #CMFReactComponent,
	#category : #'GReaSe-Components-BlockEditor'
}

{ #category : #'as yet unclassified' }
SBTSBlock3D >> areaThickness [

	^ 0.02
]

{ #category : #'as yet unclassified' }
SBTSBlock3D >> blockScale [

	^ 0.3
]

{ #category : #'as yet unclassified' }
SBTSBlock3D >> blockThickness [

	^ 0.02
]

{ #category : #'as yet unclassified' }
SBTSBlock3D >> render: props [

	| block bounds xy hovered areaRef |
	block := props at: #block.
	bounds := block at: #bounds.
	xy := bounds first * self blockScale @ (bounds second * self blockScale).
	areaRef := self useRef: nil.
	
	hovered := (self useContext: SBTSHoveredContext) get = areaRef get.
	
	^ (self godot: #Spatial)
		name: 'TSBlock';
		groups: #('tsblock');
		children: {
			(self godot: #Spatial)
				name: 'Scaled';
				scale: xy @ self blockThickness;
				children: {
					(self godot: #MeshInstance) mesh: {
						(self godot: #BoxShape)
							extents: 0.5 @ 0.5 @ 0.5;
							margin: 0.001}}.
			(self godot: #Spatial)
				name: 'Blocks';
				children: ((block at: #children) collect: [:child |
					(child at: #class)
						caseOf: {
							[#block] -> [
								SBTSBlock3D asReactNodeBuilder
									props: {#block -> child};
									build].
							[#insert] -> [nil]}
						otherwise: [nil]]).
			(self godot: #Area)
				ref: areaRef;
				collision_layer: 3;
				scale: xy @ self areaThickness;
				children: {self godot: #CollisionShape}}
]

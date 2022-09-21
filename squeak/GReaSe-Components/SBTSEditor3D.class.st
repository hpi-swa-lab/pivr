Class {
	#name : #SBTSEditor3D,
	#superclass : #CMFReactComponent,
	#category : #'GReaSe-Components-BlockEditor'
}

{ #category : #'as yet unclassified' }
SBTSEditor3D >> render: props [

	| root hovered grabbed |
	" TODO: dont parse this each time but rather store a pointer to an open SBEditor "
	root := (SBJavascript parseToplevel: '2 + 2')
		fullBounds;
		exportStructure.
	
	hovered := self useState: nil.
	grabbed := self useState: nil.
	
	^ SBTSHoveredContext asProviderNodeWithValue: hovered children: {
		SBTSGrabbedContext asProviderNodeWithValue: grabbed children: {
			(self godot: #ARVRCamera) current: true.
			SBTSGrabber3D asReactNodeBuilder build.
			SBTSBlock3D asReactNodeBuilder
				props: {#block -> root};
				build}}
]

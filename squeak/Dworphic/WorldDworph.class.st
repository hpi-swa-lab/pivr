Class {
	#name : #WorldDworph,
	#superclass : #GRComponent,
	#category : #Dworphic
}

{ #category : #rendering }
WorldDworph >> render: props [

	| headTransform headTransformSubscription worldRef |
	self useVR.
	headTransform := self useState: Matrix4x4 identity.
	headTransformSubscription := self useCallback: [:t | headTransform set: t] dependencies: {}.
	worldRef := self useRef: nil.
	
	^ GRProvider
		values: {#headTransform -> headTransform get. #worldPortal -> worldRef get}
		children: {
			(self godot: #ARVROrigin) children: {
				(self godot: #ARVRCamera) subscribeTo: #transform do: headTransformSubscription.
				ControllerInfoDworph new
					left: false;
					children: {props at: #children ifAbsent: [#()]}.
				(self godot: #Spatial) ref: [:node | worldRef set: node]}}
]

{ #category : #hooks }
WorldDworph >> useVR [

	self
		useEffect: [ | openxr |
			openxr := GRReactCurrentSession value
				callOn: 'ARVRServer'
				method: 'find_interface'
				arguments: {'OpenXR'}.
			openxr ifNotNil: [ | sceneTree viewport |
				GRReactCurrentSession value
					callOn: openxr
					method: 'initialize'
					arguments: {}.
				sceneTree := GRReactCurrentSession value
					callOn: 'Engine'
					method: 'get_main_loop'
					arguments: {}.
				viewport := GRReactCurrentSession value get: 'root' of: sceneTree.
				GRReactCurrentSession value set: 'hdr' of: viewport to: false.
				GRReactCurrentSession value set: 'vsync_enabled' of: 'OS' to: true.
				GRReactCurrentSession value set: 'iterations_per_second' of: 'Engine' to: 90.
				GRReactCurrentSession value set: 'arvr' of: viewport to: true].
			nil]
		dependencies: {}
]

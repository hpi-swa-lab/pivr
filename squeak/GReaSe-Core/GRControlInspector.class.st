Class {
	#name : #GRControlInspector,
	#superclass : #GRComponent,
	#category : #'GReaSe-Core-Debug'
}

{ #category : #'as yet unclassified' }
GRControlInspector >> render: props [

	| eventRef |
	eventRef := self useGodotRef.
	
	GRReact enableCodeMapping ifFalse: [^ nil].
	
	^ GRExternalEvents new
		onButton: [:pressed :button :position |
			pressed ifTrue: [
				((eventRef get grAsClass: #GRExternalEvents) controlsAtPosition: position) collect: [:object | | path hostConfig p |
					path := (object grAsClass: #GDControl) getPath.
					hostConfig := CMFCurrentReact value hostConfig.
					p := object autoCast.
					
					CMFCurrentReact value codeLocations associations
						detect: [:location | '/root/GRRoot', (hostConfig fullPathFor: location key) = path]
						ifFound: [:location | location value]
						ifNone: [nil]]]];
		ref: eventRef
]

"
An ApplicationDworph groups related nodes in a single subtree. All nodes that a user interacts with should be a descendant of an application. This allows us to interact with applications as a whole; for instance, applications can be opened, closed, and minimized as a whole. Applications can also take control of global resources like the skybox and the active hands.

The use of portals to render a node outside of the ApplicationDworph is allowed.

The ApplicationDworph itself should have a ???WorldDworph??? (subject to change) as an ancestor.
"
Class {
	#name : #ApplicationDworph,
	#superclass : #GRComponent,
	#category : #'Dworphic-Core'
}

{ #category : #'as yet unclassified' }
ApplicationDworph >> render: props [

	"appId := self useState: nil."
	"appRegistry := self useProvided: #appRegistry."
	
	"visible := self useState: true."
	
	"self useEffect: [ | name |
		name := props at: #appName ifAbsent: ['Unnamed app'].
		appId set: (appRegistry register: (DworphicApplicationInfo new
			name: name;
			visibilityBlock: visible setter)).
		
		nil] dependencies: #()."

	^ GDSpatial new
		setAll: props;
		children: (props at: #children ifAbsent: #())
]

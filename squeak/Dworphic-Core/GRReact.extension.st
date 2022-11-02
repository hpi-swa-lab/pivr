Extension { #name : #GRReact }

{ #category : #'*Dworphic-Core-preferences' }
GRReact class >> autoStartApplications [
	<preference: 'Auto Start Applications List' category: 'GReaSe' description: 'Comma-separated List of Component Class Names' type: #String>

	^ AutoStartApplications ifNil: ['AppControl']
]

{ #category : #'*Dworphic-Core-preferences' }
GRReact class >> autoStartApplications: aBoolean [

	AutoStartApplications := aBoolean
]

{ #category : #'*Dworphic-Core-preferences' }
GRReact class >> invertSimulatorCamera [
	<preference: 'invertSimulatorCamera' category: 'GReaSe' description: 'Inverts camera movement' type: #Boolean>

	^ InvertSimulatorCamera ifNil: [false]
]

{ #category : #'*Dworphic-Core-preferences' }
GRReact class >> invertSimulatorCamera: aBoolean [

	InvertSimulatorCamera := aBoolean
]

{ #category : #'*Dworphic-Core-preferences' }
GRReact class >> useSimulator [
	<preference: 'Use Simulator' category: 'GReaSe' description: 'Ignore VR if available and always start simulator' type: #Boolean>

	^ UseSimulator ifNil: [false]
]

{ #category : #'*Dworphic-Core-preferences' }
GRReact class >> useSimulator: aBoolean [

	UseSimulator := aBoolean
]

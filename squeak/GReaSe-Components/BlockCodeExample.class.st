Class {
	#name : #BlockCodeExample,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-BlockCode'
}

{ #category : #'as yet unclassified' }
BlockCodeExample class >> exampleStructure [

	^ Json readFrom: (ReadStream on: self exampleStructureString)

]

{ #category : #'as yet unclassified' }
BlockCodeExample class >> exampleStructureString [

	^  '{"vrInteractionAllowed":false,"type":"methodRoot","color":"#FFFFFF","class":"block","id":62,"children":[{"vrInteractionAllowed":false,"type":"classNameInput","color":"#FFFFFF","class":"block","id":28,"children":[{"vrInteractionAllowed":false,"color":"#000000","class":"text","id":27,"bounds":[156,128,107,14],"contents":"OrderedCollection"}],"bounds":[154,127,111,16]},{"vrInteractionAllowed":false,"type":"method","highlight":"_sb_none","color":"#FFFFFF","class":"block","id":61,"children":[{"vrInteractionAllowed":true,"type":"unary_selector","highlight":"_sb_none","color":"#FFFFFF","class":"block","id":31,"children":[{"vrInteractionAllowed":true,"type":null,"highlight":"major_declaration","color":"#FFFFFF","class":"block","id":30,"children":[{"vrInteractionAllowed":true,"regex":"([A-Za-z_][A-Za-z0-9_]*)","color":"#000000","class":"text","id":29,"bounds":[166,155,25,16],"contents":"last"}],"bounds":[162,151,33,24]}],"bounds":[158,147,41,32]},{"class":"hardLineBreak"},{"vrInteractionAllowed":true,"type":"empty","highlight":"variable.part","color":"#FFFFFF00","class":"block","id":33,"children":[{"vrInteractionAllowed":true,"regex":"","color":"#000000","class":"text","id":32,"bounds":[162,185,4,14],"contents":""}],"bounds":[158,181,12,22]},{"class":"hardLineBreak"},{"vrInteractionAllowed":true,"type":"keyword_message","highlight":"_sb_none","color":"#FFFFFF","class":"block","id":51,"children":[{"vrInteractionAllowed":true,"type":"binary_message","highlight":"_sb_none","color":"#FFFFFF","class":"block","id":40,"children":[{"vrInteractionAllowed":true,"type":"identifier","highlight":"variable","color":"#FFFFFF","class":"block","id":35,"children":[{"vrInteractionAllowed":true,"regex":"([A-Za-z_][A-Za-z0-9_]*)","color":"#0000FF","class":"text","id":34,"bounds":[170,217,57,16],"contents":"firstIndex"}],"bounds":[166,213,65,24]},{"vrInteractionAllowed":true,"type":"binary_operator","highlight":"variable.part","color":"#FFFFFF00","class":"block","id":37,"children":[{"vrInteractionAllowed":true,"regex":"([-+\\\\/*~<>=@,%|&?!]+)","color":"#000000","class":"text","id":36,"bounds":[237,217,10,16],"contents":">"}],"bounds":[233,213,18,24]},{"vrInteractionAllowed":true,"type":"identifier","highlight":"variable","color":"#FFFFFF","class":"block","id":39,"children":[{"vrInteractionAllowed":true,"regex":"([A-Za-z_][A-Za-z0-9_]*)","color":"#0000FF","class":"text","id":38,"bounds":[257,217,55,16],"contents":"lastIndex"}],"bounds":[253,213,63,24]}],"bounds":[162,209,158,32]},{"vrInteractionAllowed":true,"type":"keyword","highlight":"variable.part","color":"#FFFFFF00","class":"block","id":42,"children":[{"vrInteractionAllowed":true,"regex":"([A-Za-z_][A-Za-z0-9_]*\\:)","color":"#000000","class":"text","id":41,"bounds":[326,213,38,16],"contents":"ifTrue:"}],"bounds":[322,209,46,24]},{"vrInteractionAllowed":true,"type":"block","highlight":"_sb_none","color":"#F8F8F8","class":"block","id":50,"children":[{"vrInteractionAllowed":true,"regex":"\\[","color":"#AF00DB","class":"text","id":43,"bounds":[374,213,5,16],"contents":"["},{"vrInteractionAllowed":true,"type":"unary_message","highlight":"_sb_none","color":"#F8F8F8","class":"block","id":48,"children":[{"vrInteractionAllowed":true,"type":"identifier","highlight":"variable","color":"#F8F8F8","class":"block","id":45,"children":[{"vrInteractionAllowed":true,"regex":"([A-Za-z_][A-Za-z0-9_]*)","color":"#0000FF","class":"text","id":44,"bounds":[389,221,20,16],"contents":"self"}],"bounds":[385,217,28,24]},{"vrInteractionAllowed":true,"type":null,"highlight":"variable.part","color":"#F8F8F800","class":"block","id":47,"children":[{"vrInteractionAllowed":true,"regex":"([A-Za-z_][A-Za-z0-9_]*)","color":"#000000","class":"text","id":46,"bounds":[419,221,126,16],"contents":"errorNoSuchElement"}],"bounds":[415,217,134,24]}],"bounds":[381,213,172,32]},{"vrInteractionAllowed":true,"regex":"\\]","color":"#AF00DB","class":"text","id":49,"bounds":[555,213,5,16],"contents":"]"}],"bounds":[370,209,194,40]}],"bounds":[158,205,410,48]},{"class":"hardLineBreak"},{"vrInteractionAllowed":true,"type":"return","highlight":"_sb_none","color":"#FFFFFF","class":"block","id":60,"children":[{"vrInteractionAllowed":true,"regex":"\\^","color":"#AF00DB","class":"text","id":52,"bounds":[162,259,10,16],"contents":"^"},{"vrInteractionAllowed":true,"type":"keyword_message","highlight":"_sb_none","color":"#FFFFFF","class":"block","id":59,"children":[{"vrInteractionAllowed":true,"type":"identifier","highlight":"variable","color":"#FFFFFF","class":"block","id":54,"children":[{"vrInteractionAllowed":true,"regex":"([A-Za-z_][A-Za-z0-9_]*)","color":"#0000FF","class":"text","id":53,"bounds":[182,267,31,16],"contents":"array"}],"bounds":[178,263,39,24]},{"vrInteractionAllowed":true,"type":"keyword","highlight":"variable.part","color":"#FFFFFF00","class":"block","id":56,"children":[{"vrInteractionAllowed":true,"regex":"([A-Za-z_][A-Za-z0-9_]*\\:)","color":"#000000","class":"text","id":55,"bounds":[223,267,16,16],"contents":"at:"}],"bounds":[219,263,24,24]},{"vrInteractionAllowed":true,"type":"identifier","highlight":"variable","color":"#FFFFFF","class":"block","id":58,"children":[{"vrInteractionAllowed":true,"regex":"([A-Za-z_][A-Za-z0-9_]*)","color":"#0000FF","class":"text","id":57,"bounds":[249,267,55,16],"contents":"lastIndex"}],"bounds":[245,263,63,24]}],"bounds":[174,259,138,32]}],"bounds":[158,255,158,40]}],"bounds":[154,143,418,156]}],"bounds":[144,118,500,190]}' 

]

{ #category : #'as yet unclassified' }
BlockCodeExample >> editorTranslation [

	^ Vector3 value: 0
]

{ #category : #'as yet unclassified' }
BlockCodeExample >> interactionComponent [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
BlockCodeExample >> render: props [

	| handAreas grabReleaseCallbacks |
	self useCenterOnScreen: 1.
	handAreas := self useState: OrderedCollection new.
	grabReleaseCallbacks := self useState: OrderedCollection new.

	^ (GRProvider
		values: {
			#addHandArea -> [:area | Transcript showln: 'add'.handAreas set: (handAreas get copyWith: area)].
			#removeHandArea -> [:area | Transcript showln: 'remove'.handAreas set: (handAreas get copyWithout: area)].
			#getHandAreas -> [handAreas get].
			#addGrabReleaseCallbacks -> [:callbacks |
				grabReleaseCallbacks set: (grabReleaseCallbacks get copyWith: callbacks)].
			#removeGrabReleaseCallbacks -> [:callbacks|
				grabReleaseCallbacks set: (grabReleaseCallbacks get copyWithout: callbacks)].
			#getGrabReleaseCallbacks -> [grabReleaseCallbacks get]}
		children: {(self godot: #Spatial)
			children: {
				BlockCodeEditor new
					translation: self editorTranslation;
					structure: (self class exampleStructure);
					layoutParams: (CodeBlockLayoutParamters new
						blockDepth: 0.01;
						morphicScale: 0.003).
				self interactionComponent.
				GrabbableCube new.
			}})
]

{ #category : #'as yet unclassified' }
BlockCodeExample >> useCenterOnScreen: screenIndex [

	^ self useEffect: [ | screenSize session windowSize doCenter |
		session := GRReactCurrentSession value.
		doCenter := [
			session callOn: 'OS'
				method: 'set_current_screen'
				arguments: {screenIndex}].
		
		doCenter value.
		screenSize := session callOn: 'OS'
			method: 'get_screen_size'.
		windowSize := session callOn: 'OS'
			method: 'get_real_window_size'.
		session callOn: 'OS'
			method: 'set_window_position'
			arguments: {(screenSize - windowSize) / 2}.
		"We need to center again because for some reason Godot will put the window on the original screen after the previous call"
		doCenter value.]
		dependencies: #()
]

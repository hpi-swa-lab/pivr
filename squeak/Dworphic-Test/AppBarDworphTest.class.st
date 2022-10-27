Class {
	#name : #AppBarDworphTest,
	#superclass : #GRTestCase,
	#category : #'Dworphic-Test'
}

{ #category : #'as yet unclassified' }
AppBarDworphTest >> testAppBarClose [

	self openComponent: [
		AlternativeWorldDworph new children: {
			Avatar new.
			AppBarDworph new.
			[ | openApplication |
				openApplication := GRComponent basicNew useProvided: #openApplication.
				GRComponent basicNew
					useApplication: [
						DworphicApplicationDescription new
							render: [[nil] asComponent];
							name: 'Test 1']
					dependencies: {}.
				GRComponent basicNew
					useApplication: [
						DworphicApplicationDescription new
							render: [[nil] asComponent];
							name: 'Test 2']
					dependencies: {}.
				nil] asComponent}].
	
	self
		assert: #('Test 1' 'Test 2')
		equals: ((godotTree allNodesOfType: #Label3D) allButFirst collect: #text).
	self tick: {
		(godotTree firstNodeThat: [:node | (node properties includesKey: #text) and: [node text = 'Test 1']]) parent children second
			signal: #'area_entered'
			with: {self controllerCollider: #left}}.
	self tick: {(self controllerNode: #left) toggleTrigger: true}.
	self assert: #('Test 2') equals: ((godotTree allNodesOfType: #Label3D) allButFirst collect: #text)
]

{ #category : #'as yet unclassified' }
AppBarDworphTest >> testAppBarList [

	self openComponent: [
		AlternativeWorldDworph new children: {
			Avatar new.
			AppBarDworph new.
			[ | openApplication |
				openApplication := GRComponent basicNew useProvided: #openApplication.
				GRComponent basicNew
					useApplication: [
						DworphicApplicationDescription new
							render: [[nil] asComponent];
							name: 'Test 1']
					dependencies: {}.
				GRComponent basicNew
					useApplication: [
						DworphicApplicationDescription new
							render: [[nil] asComponent];
							name: 'Test 2']
					dependencies: {}.
				nil] asComponent}].
	
	self
		assert: #('Test 1' 'Test 2')
		equals: ((godotTree allNodesOfType: #Label3D) allButFirst collect: #text)
]

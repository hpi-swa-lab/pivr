Class {
	#name : #BaselineOfGReaSe,
	#superclass : #BaselineOf,
	#category : #BaselineOfGReaSe
}

{ #category : #'as yet unclassified' }
BaselineOfGReaSe >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec baseline: 'SBTreeSitter' with: [spec repository: 'github://hpi-swa-lab/sb-tree-sitter'].
		spec baseline: 'CmfcmfReact' with: [spec repository: 'github://cmfcmf/ReactS:main/packages'].
		spec
			baseline: 'SBTreeSitter'
			with: [spec repository: 'github://hpi-swa-lab/sb-tree-sitter:master/packages'].
		spec
			baseline: '3DTransform'
			with: [spec repository: 'github://hpi-swa-lab/squeak-graphics-opengl:main/3DTransform/src/'].
		spec package: 'OSProcess' with: [spec repository: 'http://www.squeaksource.com/OSProcess'].
		spec
			package: 'GReaSe-React' with: [spec requires: #('CmfcmfReact')];
			package: 'GReaSe-Core' with: [spec requires: #('GReaSe-React' '3DTransform' 'OSProcess')];
			package: 'Godot-Internal-Generation' with: [
				spec
					requires: #('GReaSe-Core');
					postLoadDoIt: #postLoadGenerator];
			package: 'GReaSe-Components'
				with: [spec requires: #('GReaSe-Core' 'Godot-Internal-Generation' 'SBTreeSitter')];
			package: 'GReaSe-Test' with: [spec requires: #('GReaSe-Core')];
			package: 'Dworphic-Core' with: [spec requires: #('GReaSe-Core' 'Godot-Internal-Generation')];
			package: 'Dworphic-Test'
				with: [spec requires: #('Dworphic-Core' 'GReaSe-Test' 'GReaSe-Components')].
		spec group: 'default' with: #('GReaSe-Components' 'Dworphic-Core').
		spec group: 'tests' with: #('Dworphic-Test' 'GReaSe-Test').
		spec group: 'all' with: #('GReaSe-Components' 'Dworphic-Core' 'GReaSe-Test' 'Dworphic-Test')]
]

{ #category : #'as yet unclassified' }
BaselineOfGReaSe >> postLoadGenerator [

	GDApiObjectsGenerator generate
]

{ #category : #'as yet unclassified' }
BaselineOfGReaSe >> projectClass [

	^ Smalltalk at: #MetacelloCypressBaselineProject ifAbsent: [super projectClass]
]

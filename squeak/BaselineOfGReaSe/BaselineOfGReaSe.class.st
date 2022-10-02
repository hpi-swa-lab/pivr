Class {
	#name : #BaselineOfGReaSe,
	#superclass : #BaselineOf,
	#category : #BaselineOfGReaSe
}

{ #category : #'as yet unclassified' }
BaselineOfGReaSe >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec postLoadDoIt: #postLoad.
		spec baseline: 'SBTreeSitter' with: [spec repository: 'github://hpi-swa-lab/sb-tree-sitter'].
		spec baseline: 'CmfcmfReact' with: [spec repository: 'github://cmfcmf/ReactS:main/packages'].
		spec
			baseline: '3DTransform'
			with: [spec repository: 'github://hpi-swa-lab/squeak-graphics-opengl:main/3DTransform/src/'].
		spec project: 'OSProcess' with: [
			spec
				className: 'ConfigurationOfOSProcess';
				repository: 'http://www.squeaksource.com/MetacelloRepository';
				versionString: #stable;
				loads: #('Core')].
		spec
			package: 'GReaSe-React' with: [spec requires: #('CmfcmfReact')];
			package: 'GReaSe-Core' with: [spec requires: #('GReaSe-React' '3DTransform')];
			package: 'GReaSe-Components' with: [spec requires: #('GReaSe-Core')];
			package: 'GReaSe-Test' with: [spec requires: #('GReaSe-Core')];
			package: 'Dworphic-Core' with: [spec requires: #('GReaSe-Core')];
			package: 'Dworphic-Test' with: [spec requires: #('Dworphic-Core')].
		spec group: 'default' with: #('GreaSe-Components' 'Dworphic').
		spec group: 'test' with: #('Dworphic-Test' 'GReaSe-Test')]
]

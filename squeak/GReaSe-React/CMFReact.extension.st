Extension { #name : #CMFReact }

{ #category : #'*GReaSe-React' }
CMFReact >> useProvided: aSymbol [

	| hook |
	hook := self getHook: GRHookUseProvided ifAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			yourself].
	^ hook getValueBasedOnNodeTree: self elementTree setLastValue: true
]

{ #category : #'*GReaSe-React' }
CMFReact >> useProvided: aSymbol namespace: anotherSymbol [

	| hook |
	hook := self getHook: GRHookUseProvided ifAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			namespace: anotherSymbol;
			yourself].
	hook namespace: anotherSymbol.
	^ hook getValueBasedOnNodeTree: self elementTree setLastValue: true
]

{ #category : #'*GReaSe-React' }
CMFReact >> useProvidedRef: aSymbol [

	| hook |
	hook := self getHook: GRHookUseProvidedRef ifAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			yourself].
	^ hook
]

{ #category : #'*GReaSe-React' }
CMFReact >> useProvidedRef: aSymbol namespace: anotherSymbol [

	| hook |
	hook := self getHook: GRHookUseProvidedRef ifAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			namespace: anotherSymbol;
			yourself].
	hook namespace: anotherSymbol.
	^ hook
]

{ #category : #'*GReaSe-React' }
CMFReact >> useRemoteRef [

	^ self getHook: GRHookUseRemoteRef ifAbsent: [:node | GRHookUseRemoteRef new hostConfig: self]
]

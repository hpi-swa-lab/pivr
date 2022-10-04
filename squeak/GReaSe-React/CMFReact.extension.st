Extension { #name : #CMFReact }

{ #category : #'*GReaSe-React' }
CMFReact >> useProvided: aSymbol [

	| hook |
	hook := self getHook: GRHookUseProvided IfAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			yourself].
	^ hook getValueBasedOnNodeTree: self elementTree setLastValue: true
]

{ #category : #'*GReaSe-React' }
CMFReact >> useProvided: aSymbol namespace: anotherSymbol [

	| hook |
	hook := self getHook: GRHookUseProvided IfAbsent: [:node |
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
	hook := self getHook: GRHookUseProvidedRef IfAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			yourself].
	^ hook
]

{ #category : #'*GReaSe-React' }
CMFReact >> useProvidedRef: aSymbol namespace: anotherSymbol [

	| hook |
	hook := self getHook: GRHookUseProvidedRef IfAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			namespace: anotherSymbol;
			yourself].
	hook namespace: anotherSymbol.
	^ hook
]

Extension { #name : #CMFReact2 }

{ #category : #'*GRease-React' }
CMFReact2 >> useProvided: aSymbol [

	| hook |
	hook := currentFiber getHook: GRHookUseProvided IfAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			yourself].
	^ hook getValueBasedOnFiber: currentFiber setLastValue: true
]

{ #category : #'*GRease-React' }
CMFReact2 >> useProvided: aSymbol namespace: anotherSymbol [

	| hook |
	hook := currentFiber getHook: GRHookUseProvided IfAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			namespace: anotherSymbol;
			yourself].
	hook namespace: anotherSymbol.
	^ hook getValueBasedOnFiber: currentFiber setLastValue: true
]

{ #category : #'*GRease-React' }
CMFReact2 >> useProvidedRef: aSymbol [

	| hook |
	hook := currentFiber getHook: GRHookUseProvidedRef IfAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			yourself].
	^ hook
]

{ #category : #'*GRease-React' }
CMFReact2 >> useProvidedRef: aSymbol namespace: anotherSymbol [

	| hook |
	hook := currentFiber getHook: GRHookUseProvidedRef IfAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			namespace: anotherSymbol;
			yourself].
	hook namespace: anotherSymbol.
	^ hook
]

{ #category : #'*GRease-React' }
CMFReact2 >> useRemoteRef [

	^ currentFiber
		getHook: GRHookUseRemoteRef
		IfAbsent: [:node | GRHookUseRemoteRef new hostConfig: self hostConfig]
]

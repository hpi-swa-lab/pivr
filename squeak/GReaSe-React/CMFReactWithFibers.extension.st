Extension { #name : #CMFReactWithFibers }

{ #category : #'*GRease-React' }
CMFReactWithFibers >> useProvided: aSymbol [

	| hook |
	hook := currentFiber getHook: GRHookUseProvided IfAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			yourself].
	^ hook getValueBasedOnFiber: currentFiber setLastValue: true
]

{ #category : #'*GRease-React' }
CMFReactWithFibers >> useProvided: aSymbol namespace: anotherSymbol [

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
CMFReactWithFibers >> useProvidedRef: aSymbol [

	| hook |
	hook := currentFiber getHook: GRHookUseProvidedRef IfAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			yourself].
	^ hook
]

{ #category : #'*GRease-React' }
CMFReactWithFibers >> useProvidedRef: aSymbol namespace: anotherSymbol [

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
CMFReactWithFibers >> useRemoteRef [

	^ currentFiber
		getHook: GRHookUseRemoteRef
		IfAbsent: [:node | GRHookUseRemoteRef new hostConfig: self hostConfig]
]

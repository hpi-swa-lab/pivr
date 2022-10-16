Extension { #name : #CMFReactWithFibers }

{ #category : #'*GRease-React' }
CMFReactWithFibers >> useGodotRef [

	^ currentFiber
		getHook: GRHookUseGodotRef
		ifAbsent: [:node | GRHookUseGodotRef new hostConfig: self hostConfig]
]

{ #category : #'*GRease-React' }
CMFReactWithFibers >> useProvided: aSymbol [

	| hook |
	hook := currentFiber getHook: GRHookUseProvided ifAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			yourself].
	^ hook getValueAndRemember: true
]

{ #category : #'*GRease-React' }
CMFReactWithFibers >> useProvided: aSymbol namespace: anotherSymbol [

	| hook |
	hook := currentFiber getHook: GRHookUseProvided ifAbsent: [:node |
		GRHookUseProvided new
			symbol: aSymbol node: node;
			namespace: anotherSymbol;
			yourself].
	hook namespace: anotherSymbol.
	^ hook getValueAndRemember: true
]

{ #category : #'*GRease-React' }
CMFReactWithFibers >> useProvidedRef: aSymbol [

	| hook |
	hook := currentFiber getHook: GRHookUseProvidedRef ifAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			yourself].
	^ hook
]

{ #category : #'*GRease-React' }
CMFReactWithFibers >> useProvidedRef: aSymbol namespace: anotherSymbol [

	| hook |
	hook := currentFiber getHook: GRHookUseProvidedRef ifAbsent: [:node |
		GRHookUseProvidedRef new
			symbol: aSymbol node: node;
			namespace: anotherSymbol;
			yourself].
	hook namespace: anotherSymbol.
	^ hook
]

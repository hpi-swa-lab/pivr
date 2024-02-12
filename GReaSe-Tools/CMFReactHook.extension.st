Extension { #name : #CMFReactHook }

{ #category : #'*GReaSe-Tools' }
CMFReactHook >> hookName: name [

	"TODO (hack) makes use of an instance variable called hookName. One can probably create the instance variable dynamically using addInstVarName:, however the component Browser could run into issues since the instance variable is not declared at all times and there is no non-error-if-absent getter for it."
	hookName := name.
]

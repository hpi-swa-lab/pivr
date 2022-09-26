Extension { #name : #CMFReactNodeTreeEntry }

{ #category : #'*GreaSe-Core' }
CMFReactNodeTreeEntry >> godotPath [

	| current path |
	current := self.
	path := ''.
	[current] whileNotNil: [
		current node class = CMFReactNodePortal ifTrue: [
			self assert: current node container get notNil.
			current := current node container get].
		current node isGodotNode ifTrue: [path := (current node isResource ifTrue: [':'] ifFalse: ['/']), current node godotId, path].
		current := current parent].
	^ path
]

{ #category : #'*GreaSe-Core' }
CMFReactNodeTreeEntry >> renderResultGodotPaths [

	| current path |
	current := self.
	path := ''.
	[current] whileNotNil: [
		current node class = CMFReactNodePortal ifTrue: [
			self assert: current node container get notNil.
			current := current node container get].
		current node isGodotNode ifTrue: [path := (current node isResource ifTrue: [':'] ifFalse: ['/']), current node godotId, path].
		current := current parent].
	
	^ (self node isGodotNode or: [renderResult isNil])
		ifTrue: [{path}]
		ifFalse: [
			(self childrenTreeNodes gather: [:child | child renderedGodotNodeEntries]) collect: [:node | path, ((node isResource ifTrue: [':'] ifFalse: ['/']), node godotId)]]
]

{ #category : #'*GreaSe-Core' }
CMFReactNodeTreeEntry >> renderedGodotNodeEntries [

	self node isGodotNode ifTrue: [^ {self node}].
	self node class = CMFReactNodePortal ifTrue: [^ {}].
	^ childrenTreeNodes gather: [:child | child renderedGodotNodeEntries]
]

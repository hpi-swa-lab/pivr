Extension { #name : #CMFReactNodeTreeEntry }

{ #category : #'*GreaSe-Core' }
CMFReactNodeTreeEntry >> godotPath [

	| current path |
	current := self.
	path := ''.
	[current] whileNotNil: [
		(current node class = CMFReactNodePortal and: [current node container notNil]) ifTrue: [current := current node container].
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
		(current node class = CMFReactNodePortal and: [current node container notNil]) ifTrue: [current := current node container].
		current node isGodotNode ifTrue: [path := (current node isResource ifTrue: [':'] ifFalse: ['/']), current node godotId, path].
		current := current parent].
	
	^ (self node isGodotNode or: [renderResult isNil])
		ifTrue: [{path}]
		ifFalse: [renderResult asOrderedCollection collect: [:node | path, ((node isResource ifTrue: [':'] ifFalse: ['/']), node godotId)]]
]

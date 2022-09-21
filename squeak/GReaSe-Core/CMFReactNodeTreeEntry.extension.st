Extension { #name : #CMFReactNodeTreeEntry }

{ #category : #'*GreaSe-Core' }
CMFReactNodeTreeEntry >> godotPath [

	| current path |
	current := self.
	path := ''.
	[current] whileNotNil: [
		current node isGodotNode ifTrue: [
			path := (current node isResource ifTrue: [':'] ifFalse: ['/']), current node godotId, path].
		current := current parent].
	^ path
]
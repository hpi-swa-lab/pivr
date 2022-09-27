Extension { #name : #BlockClosure }

{ #category : #'*GReaSe-Core' }
BlockClosure >> asComponent [

	^ self asReactNodeBuilder build
]

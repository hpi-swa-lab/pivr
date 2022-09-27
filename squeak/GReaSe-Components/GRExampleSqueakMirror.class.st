Class {
	#name : #GRExampleSqueakMirror,
	#superclass : #GRComponent,
	#category : #'GReaSe-Components-Examples'
}

{ #category : #'as yet unclassified' }
GRExampleSqueakMirror >> render: props [

	| image |
	image := self useState: nil.
	
	self
		useEffect: [
			image set: (GRReactCurrentSession value createInstanceOf: 'Image').
			GRReactCurrentSession value
				callOn: image get
				method: #'create_from_data'
				arguments: {64. 64. false. 5. (Display copy: (0 @ 0 extent: 64 @ 64)) bits}.
			[
				GRReactCurrentSession value freeInstance: image get.
				image set: nil]]
		dependencies: {}.
	
	^ (self godot: #VBoxContainer) children: {
		image get ifNotNil: [
			(self godot: #TextureRect) texture: ((self godot: #ImageTexture)
				call: #'create_from_image'
				arguments: {image get. 7})]}
]

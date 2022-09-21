Class {
	#name : #GRVariantTest,
	#superclass : #TestCase,
	#category : #'GReaSe-Core'
}

{ #category : #'as yet unclassified' }
GRVariantTest >> testArrayWithStrings [
	" Godot: {'a': 'b'} "

	self
		assert: {'a'. 'b'}
		equals: (GDSocketListener readVariantFrom: #[19 0 0 0 2 0 0 0 4 0 0 0 1 0 0 0 97 0 0 0 4 0 0 0 1 0 0 0 98 0 0 0] readStream).
	self
		assert: {'a'. 'b'}
		equals: (GDSocketListener readVariantFrom: (ByteArray streamContents: [:stream | {'a'. 'b'} putVariantOn: stream]) readStream)
]

{ #category : #'as yet unclassified' }
GRVariantTest >> testDictionaryWithStrings [
	" Godot: {'a': 'b'} "

	self
		assert: (Dictionary new
			at: 'a' put: 'b';
			yourself)
		equals: (GDSocketListener readVariantFrom: #[18 0 0 0 1 0 0 0 4 0 0 0 1 0 0 0 97 0 0 0 4 0 0 0 1 0 0 0 98 0 0 0] readStream)
]

{ #category : #'as yet unclassified' }
GRVariantTest >> testNodePath [

	self
		assert: #[15 0 0 0 2 0 0 128 0 0 0 0 0 0 0 0 2 0 0 0 46 46 0 0 4 0 0 0 80 97 116 104]
		equals: (ByteArray streamContents: [:s | (GRNodePath path: '../Path') putVariantOn: s])
]

{ #category : #'as yet unclassified' }
GRVariantTest >> testPoolVector2Array [

	self assert: #[24 0 0 0 2 0 0 0 205 204 76 64 102 102 70 64 51 51 19 192 0 0 128 192] equals: (ByteArray streamContents: [:s |
		(GRPoolVector2Array new
			add: (Vector2 x: 3.2 y: 3.1);
			add: (Vector2 x: -2.3 y: -4);
			yourself) putVariantOn: s])
]

{ #category : #'as yet unclassified' }
GRVariantTest >> testReal [

	self
		assert: 3.6
		equals: (GDSocketListener readVariantFrom: #[3 0 1 0 205 204 204 204 204 204 12 64] readStream).
	self
		assert: #[3 0 1 0 205 204 204 204 204 204 12 64]
		equals: (ByteArray streamContents: [:s | 3.6 putVariantOn: s])
]

{ #category : #'as yet unclassified' }
GRVariantTest >> testString [
	" Godot: 'abc' "

	self
		assert: 'abc'
		equals: (GDSocketListener readVariantFrom: #[4 0 0 0 3 0 0 0 97 98 99 0] readStream).
	self
		assert: 'abc'
		equals: (GDSocketListener readVariantFrom: (ByteArray streamContents: [:stream | GDSocketListener putVariant: 'abc' on: stream]) readStream)
]

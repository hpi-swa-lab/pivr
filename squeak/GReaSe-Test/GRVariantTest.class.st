Class {
	#name : #GRVariantTest,
	#superclass : #TestCase,
	#category : #'GReaSe-Test'
}

{ #category : #'as yet unclassified' }
GRVariantTest >> testArrayWithStrings [
	" Godot: {'a': 'b'} "

	self
		assert: {'a'. 'b'}
		equals: (GRSocketListener readVariantFrom: #[19 0 0 0 2 0 0 0 4 0 0 0 1 0 0 0 97 0 0 0 4 0 0 0 1 0 0 0 98 0 0 0] readStream).
	self
		assert: {'a'. 'b'}
		equals: (GRSocketListener readVariantFrom: (ByteArray streamContents: [:stream | {'a'. 'b'} putVariantOn: stream]) readStream)
]

{ #category : #'as yet unclassified' }
GRVariantTest >> testDictionaryWithStrings [
	" Godot: {'a': 'b'} "

	self
		assert: (Dictionary new
			at: 'a' put: 'b';
			yourself)
		equals: (GRSocketListener readVariantFrom: #[18 0 0 0 1 0 0 0 4 0 0 0 1 0 0 0 97 0 0 0 4 0 0 0 1 0 0 0 98 0 0 0] readStream)
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
		equals: (GRSocketListener readVariantFrom: #[3 0 1 0 205 204 204 204 204 204 12 64] readStream).
	self
		assert: #[3 0 1 0 205 204 204 204 204 204 12 64]
		equals: (ByteArray streamContents: [:s | 3.6 putVariantOn: s])
]

{ #category : #'as yet unclassified' }
GRVariantTest >> testString [
	" Godot: 'abc' "

	self
		assert: 'abc'
		equals: (GRSocketListener readVariantFrom: #[4 0 0 0 3 0 0 0 97 98 99 0] readStream).
	self
		assert: 'abc'
		equals: (GRSocketListener readVariantFrom: (ByteArray streamContents: [:stream | 'abc' putVariantOn: stream]) readStream)
]

{ #category : #'as yet unclassified' }
GRVariantTest >> testTransform [

	| matrix |
	"Transform(Basis(), Vector3(7, 8, 9))"
	matrix := GRSocketListener readVariantFrom: #[13 0 0 0 0 0 128 63 0 0 0 0 0 0 0 0 0 0 0 0 0 0 128 63 0 0 0 0 0 0 0 0 0 0 0 0 0 0 128 63 0 0 224 64 0 0 0 65 0 0 16 65] readStream.
	self assert: matrix translation equals: (Vector3 x: 7 y: 8 z: 9).
	
	"Transform(Basis(Vector3(0, 0, 1), PI), Vector3(0, 0, 0))"
	matrix := GRSocketListener readVariantFrom: #[13 0 0 0 0 0 128 191 46 189 187 51 0 0 0 0 46 189 187 179 0 0 128 191 0 0 0 0 0 0 0 0 0 0 0 0 0 0 128 63 0 0 0 0 0 0 0 0 0 0 0 0] readStream.
	self assert: (matrix rotation closeTo: 0 @ 0 @ 180).
	
	"Transform(Basis().scaled(Vector3(3, 4, 5)), Vector3(0, 0, 0))"
	matrix := GRSocketListener readVariantFrom: #[13 0 0 0 0 0 64 64 0 0 0 0 0 0 0 0 0 0 0 0 0 0 128 64 0 0 0 0 0 0 0 0 0 0 0 0 0 0 160 64 0 0 0 0 0 0 0 0 0 0 0 0] readStream.
	self assert: (matrix scale closeTo: 3 @ 4 @ 5).
	
	"Transform(Basis(Vector3(0, 1, 0), PI), Vector3(0, 0, 0))"
	matrix := GRSocketListener readVariantFrom: #[13 0 0 0 0 0 128 191 0 0 0 0 46 189 187 179 0 0 0 0 0 0 128 63 0 0 0 0 46 189 187 51 0 0 0 0 0 0 128 191 0 0 0 0 0 0 0 0 0 0 0 0] readStream.
	matrix forwardRay.
	self assert: (matrix forwardRay direction closeTo: 0 @ 0 @ 1)
]

{ #category : #'as yet unclassified' }
GRVariantTest >> testTransformSerialize [

	| matrix bytes |
	"Transform().looking_at(Vector3(1, 2, 3), Vector3(0, 1, 0)).translated(Vector3(0, 0, -0.5))"
	bytes := #[13 0 0 0 233 220 114 191 109 22 45 190 119 214 136 190 0 0 0 0 7 92 88 63 119 214 8 191 156 232 161 62 210 208 1 191 178 65 77 191 119 214 8 62 119 214 136 62 178 65 205 62].
	matrix := GRSocketListener readVariantFrom: bytes readStream.
	self assert: bytes equals: (ByteArray streamContents: [:s | matrix putVariantOn: s])
]

{ #category : #'as yet unclassified' }
GRVariantTest >> testTransformTranslated [

	| matrix reference |
	"Transform().looking_at(Vector3(1, 2, 3), Vector3(0, 1, 0))"
	reference := Matrix4x4 lookAt: 1 @ 2 @ 3 from: 0 @ 0 @ 0 up: 0 @ 1 @ 0.
	matrix := GRSocketListener readVariantFrom: #[13 0 0 0 233 220 114 191 109 22 45 190 119 214 136 190 0 0 0 0 7 92 88 63 119 214 8 191 156 232 161 62 210 208 1 191 178 65 77 191 0 0 0 0 0 0 0 0 0 0 0 0] readStream.
	reference with: matrix do: [:a :b | self assert: (a - b) abs < 0.01].
	
	"Transform().looking_at(Vector3(1, 2, 3), Vector3(0, 1, 0)).translated(Vector3(0, 0, -0.5))"
	reference := reference localTranslatedBy: 0 @ 0 @ -0.5.
	matrix := GRSocketListener readVariantFrom: #[13 0 0 0 233 220 114 191 109 22 45 190 119 214 136 190 0 0 0 0 7 92 88 63 119 214 8 191 156 232 161 62 210 208 1 191 178 65 77 191 119 214 8 62 119 214 136 62 178 65 205 62] readStream.
	reference with: matrix do: [:a :b | self assert: (a - b) abs < 0.01]
]

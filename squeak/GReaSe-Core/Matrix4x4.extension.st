Extension { #name : #Matrix4x4 }

{ #category : #'*GReaSe-Core' }
Matrix4x4 >> forwardRay [

	| direction |
	direction := self orientation transform: 0 @ 0 @ -1.
	^ GRRay origin: self translation direction: direction normalized
]

{ #category : #'*GReaSe-Core' }
Matrix4x4 >> grEqual: anObject [

	^ self = anObject
]

{ #category : #'*GReaSe-Core' }
Matrix4x4 >> localTranslatedBy: aVector3 [

	^ self * (self class withOffset: aVector3)
]

{ #category : #'*GReaSe-Core-override' }
Matrix4x4 class >> lookAt: center from: eye up: up [

	| forward sideward upward |
	"Build a right-handed look at view matrix. The camera is positioned at eye, looks at center, and is positioned in a world where up points upwards in world space. Up is expected to be normalized already."
	forward := (eye - center) normalized.
	sideward := (up cross: forward) normalized.
	upward := forward cross: sideward.
	^ self identity
		a11: sideward x;
		a21: sideward y;
		a31: sideward z;
		a12: upward x;
		a22: upward y;
		a32: upward z;
		a13: forward x;
		a23: forward y;
		a33: forward z;
		a14: eye x;
		a24: eye y;
		a34: eye z;
		yourself
]

{ #category : #'*GReaSe-Core' }
Matrix4x4 >> putVariantOn: aStream [

	aStream nextLittleEndianNumber: 4 put: 13.
	aStream nextLittleEndianNumber: 4 put: self a11 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a12 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a13 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a21 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a22 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a23 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a31 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a32 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a33 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a14 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a24 asIEEE32BitWord.
	aStream nextLittleEndianNumber: 4 put: self a34 asIEEE32BitWord
]

{ #category : #'*GReaSe-Core' }
Matrix4x4 >> rotateVector3: aVector3 [

	| x y z rx ry rz rw |
	x := aVector3 x.
	y := aVector3 y.
	z := aVector3 z.
	
	rx := x * self a11 + (y * self a21) + (z * self a31).
	ry := x * self a12 + (y * self a22) + (z * self a32).
	rz := x * self a13 + (y * self a23) + (z * self a33).
	rw := x * self a14 + (y * self a24) + (z * self a34) + 1.
	
	^ Vector3 x: rx / rw y: ry / rw z: rz / rw
]

{ #category : #'*GReaSe-Core' }
Matrix4x4 >> rotatedGlobalBy: aDegreesNumber around: aVector [

	| out |
	out := self copy translation: 0 @ 0 @ 0.
	^ (self class withRotation: aDegreesNumber around: aVector) * out translation: self translation
]

{ #category : #'*GReaSe-Core' }
Matrix4x4 >> rotatedLocalBy: aDegreesNumber around: aVector [

	| out |
	out := self copy translation: 0 @ 0 @ 0.
	^ out * (self class withRotation: aDegreesNumber around: aVector) translation: self translation
]

{ #category : #'*GReaSe-Core' }
Matrix4x4 >> scale [

	^ Vector3 x: self a11 y: self a22 z: self a33
]

{ #category : #'*GReaSe-Core' }
Matrix4x4 >> transform: aVector3 [

	^ Vector3
		x: (self row1 dot: aVector3) + self a14
		y: (self row2 dot: aVector3) + self a24
		z: (self row3 dot: aVector3) + self a34
]

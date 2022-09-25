Extension { #name : #Matrix4x4 }

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
Matrix4x4 >> scale [

	^ Vector3 x: self a11 y: self a22 z: self a33
]

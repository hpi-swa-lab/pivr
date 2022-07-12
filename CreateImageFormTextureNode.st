Class {
	#name : #GDSCreateImageFormTextureNode,
	#superclass : #GodotNode2D,
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSCreateImageFormTextureNode >> createTextureForForm: form inTexture: texture tempImage: image [

	| arr arrptr bitmap writer |
	bitmap := (form asFormOfDepth: 32) bits.
	arr := GDPoolByteArray new.
	arr resize: bitmap byteSize.
	writer := arr write.
	arrptr := arr writeAccessPtrWrite: writer.
	self memcpyDest: arrptr src: bitmap count: bitmap byteSize.
	image createFromDataWidth: form width height: form height useMipmaps: false format: 5 data: arr.
	texture createFromImage: image.

	"arr writeAccessDestroyWrite: writer."
	texture internalVariant destroy.
	image internalVariant destroy.
	arr destroy. "this is needed to fix the GDPoolByteArray leak"
	
]

{ #category : #behavior }
GDSCreateImageFormTextureNode >> getTestTexture: texture tempImage: image [

	self createTextureForForm: Display inTexture: texture tempImage: image
]

{ #category : #behavior }
GDSCreateImageFormTextureNode >> memcpyDest: dest src: src count: count [
	<apicall: void* memcpy(void*, void*, size_t) module: 'libc.so.6'>
	^ self externalCallFailed
]

Class {
	#name : #GreasyScreenshot,
	#superclass : #GRComponent,
	#classVars : [
		'Resolution'
	],
	#category : #'Dworphic-Home'
}

{ #category : #'as yet unclassified' }
GreasyScreenshot class >> appDescription [
	<home>

	^ super appDescription
]

{ #category : #'as yet unclassified' }
GreasyScreenshot class >> resolution [
	<preference: 'Resolution' category: 'GreasyScreenshot' description: 'Resolution of the screenshot' type: #String>

	^ Resolution ifNil: 1920 @ 1080
]

{ #category : #'as yet unclassified' }
GreasyScreenshot class >> resolution: aPointOrCode [

	Resolution := aPointOrCode isPoint
		ifTrue: [aPointOrCode]
		ifFalse: [Compiler evaluate: aPointOrCode]
]

{ #category : #'as yet unclassified' }
GreasyScreenshot >> render: props [

	| takingScreenshot tookScreenshot headTransform previousSize |
	takingScreenshot := self useState: false.
	tookScreenshot := self useState: false.
	headTransform := self useProvided: #headTransform.
	previousSize := self useState: nil.

	self useButtonPress: [:event |
		event isAX ifTrue: [
			previousSize set: self viewport size.
			self viewport
				arvr: false;
				size: GreasyScreenshot resolution.
			takingScreenshot set: true.
			]] release: [] axisChange: [] side: #left.
	
	^ takingScreenshot get
		ifTrue: [ | cameraTransform |
			"cameraTransform := headTransform.
			cameraTransform rotationAroundZ: 0."
			
			cameraTransform := Matrix4x4
				lookAt: headTransform translation + (headTransform orientation transform: 0 @ 0 @ -1)
				from: headTransform translation
				up: 0 @ 1 @ 0.
			
			GDCamera new
				globalTransform: cameraTransform;
				rotationDegrees: 90 @ 0 @ 0;
				current: true;
				children: {
					GDTimer new
						autostart: true;
						oneShot: false;
						waitTime: 0.25;
						onTimeout: [
							tookScreenshot get
								ifTrue: [
									Transcript showln: 'cleaning up'.
									takingScreenshot set: false.
									tookScreenshot set: false.
									self viewport
										arvr: true;
										size: previousSize get]
								ifFalse: [ | path time timestamp |
									Transcript showln: 'taking screenshot'.
									tookScreenshot set: true.
									time := DateAndTime now.
									timestamp := Date today yyyymmdd, '-', time hour, '-', time minute, '-', time second.
									path := FileSystem disk workingDirectory / ('grease-screenshot-', timestamp, '.png').
									Transcript showln: 'Saving screenshot at ', path asString.
									self viewport getTexture getData
										flipY;
										savePngPath: path asString]]}]
		ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
GreasyScreenshot >> viewport [

	^ (GDEngine instance getMainLoop grAsClass: #GDSceneTree) root grAsClass: #GDViewport
]

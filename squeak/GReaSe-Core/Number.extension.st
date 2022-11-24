Extension { #name : #Number }

{ #category : #'*GReaSe-Core' }
Number >> asVector3 [

	^ Vector3 x: self y: self z: self
]

{ #category : #'*GReaSe-Core' }
Number >> cm [

	^ self * 0.01
]

{ #category : #'*GReaSe-Core' }
Number >> m [

	^ self
]

{ #category : #'*GReaSe-Core' }
Number >> mapFromLow: aLowNumber high: aHighNumber toLow: aTargetLowNumber high: aTargetHightNumber [

	^ self - aLowNumber / (aHighNumber - aLowNumber) * (aTargetHightNumber - aTargetLowNumber) + aTargetLowNumber
]

{ #category : #'*GReaSe-Core' }
Number >> mm [

	^ self * 0.001
]

Class {
	#name : #GDSBouncingBall,
	#superclass : #GodotSpatial,
	#instVars : [
		'speed'
	],
	#category : #'Godot-Scripts'
}

{ #category : #behavior }
GDSBouncingBall >> bounce: delta [

	self bounce: delta gravity: -10 maxSpeed: 100
]

{ #category : #behavior }
GDSBouncingBall >> bounce:delta gravity:gravity maxSpeed:maxSpeed [
|origin|
speed ifNil:[speed:=0].speed:=(((speed min:maxSpeed)))+(((gravity*delta))).origin:=self transform origin+(((GDVector3 newX:0 y:speed*delta z:0))).(((self transform origin dotB:(GDVector3 newX:0 y:1 z:0))))<0 ifTrue:[
speed:=speed*-1.origin:=self transform origin*(((GDVector3 newX:1 y:0 z:1)))].self translation:origin
]

{ #category : #behavior }
GDSBouncingBall >> physicsProcess: delta [
	
	^ nil
]

{ #category : #behavior }
GDSBouncingBall >> process: delta [

	self bounce: delta
]

{ #category : #behavior }
GDSBouncingBall >> ready [
	
	^ nil
]

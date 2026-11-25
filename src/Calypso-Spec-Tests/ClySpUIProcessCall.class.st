"
I am an action handed from a test to the UI process. I run there and keep the action's result or its error; the test waits for me and gets them back, the error raised again in the test's process.
"
Class {
	#name : 'ClySpUIProcessCall',
	#superclass : 'Object',
	#instVars : [
		'block',
		'result',
		'error',
		'done'
	],
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'instance creation' }
ClySpUIProcessCall class >> of: aBlock [

	^ self new setBlock: aBlock
]

{ #category : 'running' }
ClySpUIProcessCall >> run [
	"Runs in the UI process. Signals done even when the action fails, or the waiting process would wait forever."

	[
		[ result := block value ]
			on: Error
			do: [ :each | error := each ] ] ensure: [ done signal ]
]

{ #category : 'initialization' }
ClySpUIProcessCall >> setBlock: aBlock [

	block := aBlock.
	done := Semaphore new
]

{ #category : 'running' }
ClySpUIProcessCall >> waitForResult [

	done wait.
	error ifNotNil: [ error signal ].
	^ result
]

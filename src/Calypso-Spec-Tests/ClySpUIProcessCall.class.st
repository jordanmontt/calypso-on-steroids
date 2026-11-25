"
I carry one action from a test to the UI process, and bring back what it did.

Why: a test runs in its own process, but Calypso changes its browsers in the UI process, where it also applies system changes a bit later. When a test changed a browser from its own process, the UI process could interrupt it halfway and change the same browser; each broke the other's work, and tests failed at random. So the test does not act itself: it hands me to the UI process and waits.

How: the UI process sends me #run, which runs the action and keeps its result or its error. The test waits in #waitForResult until #run is done, then gets the result, or the error raised again in its own process, so that a failing action fails the test.
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

"
I check that a call hands back what its action did: its result, or its error.
"
Class {
	#name : 'ClySpUIProcessCallTest',
	#superclass : 'TestCase',
	#category : 'Calypso-Spec-Tests-Morphic driver',
	#package : 'Calypso-Spec-Tests',
	#tag : 'Morphic driver'
}

{ #category : 'tests' }
ClySpUIProcessCallTest >> testAnswersTheResultOfItsAction [

	| call |
	call := ClySpUIProcessCall of: [ 42 ].
	call run.
	self assert: call waitForResult equals: 42
]

{ #category : 'tests' }
ClySpUIProcessCallTest >> testRaisesTheErrorOfItsActionToTheProcessWaiting [

	| call |
	call := ClySpUIProcessCall of: [ 1 / 0 ].
	call run.
	self should: [ call waitForResult ] raise: ZeroDivide
]

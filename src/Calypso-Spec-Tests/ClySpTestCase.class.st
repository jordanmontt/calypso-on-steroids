"
I am the superclass of the browser tests. A test that opens a window must close it: I fail the test otherwise, after closing the window so that the next tests start clean.
"
Class {
	#name : 'ClySpTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'windowsBefore'
	],
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'testing' }
ClySpTestCase class >> isAbstract [

	^ self == ClySpTestCase
]

{ #category : 'running' }
ClySpTestCase >> setUp [

	super setUp.
	windowsBefore := self currentWorld systemWindows
]

{ #category : 'running' }
ClySpTestCase >> tearDown [

	| leftOpen |
	leftOpen := self currentWorld systemWindows copyWithoutAll: windowsBefore.
	leftOpen do: [ :each | each close ].
	super tearDown.
	self
		assert: leftOpen isEmpty
		description: 'The test left windows open: ' , (leftOpen collect: [ :each | each label ] as: Array) printString
]

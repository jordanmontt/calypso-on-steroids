"
I am the superclass of the browser tests. A test must close the windows it opens and must not leave processes running: I fail the test otherwise. I close the windows first, so that the next tests start clean.
"
Class {
	#name : 'ClySpTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'windowsBefore',
		'processesBefore'
	],
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'testing' }
ClySpTestCase class >> isAbstract [

	^ self == ClySpTestCase
]

{ #category : 'private' }
ClySpTestCase >> liveProcesses [

	^ Process allSubInstances reject: [ :each | each isTerminated ]
]

{ #category : 'private' }
ClySpTestCase >> processesLeftRunning [
	"The processes a test starts may take a moment to end, like the background queries of the browser plugins. Waiting also lets these lower-priority processes run."

	| deadline running |
	deadline := Time millisecondClockValue + 2000.
	[
		running := self liveProcesses copyWithoutAll: processesBefore.
		running isNotEmpty and: [ Time millisecondClockValue < deadline ] ] whileTrue: [ (Delay forMilliseconds: 10) wait ].
	^ running
]

{ #category : 'running' }
ClySpTestCase >> setUp [

	super setUp.
	"Calypso keeps one process for the life of the image to update its browsers, created the first time one updates: starting it now keeps it from being taken for a leak"
	ClyDataSource scheduleUpdateOf: ClyDataSource empty.
	windowsBefore := self currentWorld systemWindows.
	processesBefore := self liveProcesses
]

{ #category : 'running' }
ClySpTestCase >> tearDown [

	| windowsLeftOpen processesLeftRunning |
	windowsLeftOpen := self currentWorld systemWindows copyWithoutAll: windowsBefore.
	windowsLeftOpen do: [ :each | each close ].
	processesLeftRunning := self processesLeftRunning.
	super tearDown.
	self
		assert: windowsLeftOpen isEmpty
		description: [ 'The test left windows open: ' , (windowsLeftOpen collect: [ :each | each label ] as: Array) printString ].
	self
		assert: processesLeftRunning isEmpty
		description: [ 'The test left processes running: ' , (processesLeftRunning collect: [ :each | each name ] as: Array) printString ]
]

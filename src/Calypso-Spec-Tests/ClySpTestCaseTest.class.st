"
I test the window check of ClySpTestCase. Each test plays the part of SUnit by hand: it calls setUp on a ClySpTestCase, does what a test body would do, then calls tearDown and checks whether it fails. I am not a ClySpTestCase myself, so that the windows my tests open are checked by the ClySpTestCase under test only.
"
Class {
	#name : 'ClySpTestCaseTest',
	#superclass : 'TestCase',
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'tests' }
ClySpTestCaseTest >> testClosesTheWindowATestLeavesOpen [

	| testCase windowsBefore |
	windowsBefore := self currentWorld systemWindows size.
	testCase := ClySpTestCase new.
	testCase setUp.
	SystemWindow new openInWorld.
	self should: [ testCase tearDown ] raise: TestFailure.
	self assert: self currentWorld systemWindows size equals: windowsBefore
]

{ #category : 'tests' }
ClySpTestCaseTest >> testFailsWhenATestLeavesAProcessRunning [

	| testCase process |
	testCase := ClySpTestCase new.
	testCase setUp.
	process := [ Semaphore new wait ] fork.
	[ self should: [ testCase tearDown ] raise: TestFailure ] ensure: [ process terminate ]
]

{ #category : 'tests' }
ClySpTestCaseTest >> testFailsWhenATestLeavesAWindowOpen [

	| testCase |
	testCase := ClySpTestCase new.
	testCase setUp.
	SystemWindow new openInWorld.
	self should: [ testCase tearDown ] raise: TestFailure
]

{ #category : 'tests' }
ClySpTestCaseTest >> testPassesWhenATestClosesItsWindow [

	| testCase |
	testCase := ClySpTestCase new.
	testCase setUp.
	SystemWindow new openInWorld close.
	self shouldnt: [ testCase tearDown ] raise: TestFailure
]

{ #category : 'tests' }
ClySpTestCaseTest >> testPassesWhenATestMakesAnImageServiceStart [

	| testCase service |
	service := TKTParameterizableService new
		           name: 'Service started by ClySpTestCaseTest';
		           step: [ ];
		           yourself.
	testCase := ClySpTestCase new.
	testCase setUp.
	service start.
	[ self shouldnt: [ testCase tearDown ] raise: TestFailure ] ensure: [ service stop ]
]

{ #category : 'tests' }
ClySpTestCaseTest >> testPassesWhenATestMakesCalypsoUpdateItsBrowsers [

	| testCase |
	testCase := ClySpTestCase new.
	testCase setUp.
	ClyDataSource scheduleUpdateOf: ClyDataSource empty.
	self shouldnt: [ testCase tearDown ] raise: TestFailure
]

{ #category : 'tests' }
ClySpTestCaseTest >> testPassesWhenTheProcessesOfATestEndSoon [

	| testCase |
	testCase := ClySpTestCase new.
	testCase setUp.
	[ (Delay forMilliseconds: 50) wait ] forkAt: Processor userBackgroundPriority.
	self shouldnt: [ testCase tearDown ] raise: TestFailure
]

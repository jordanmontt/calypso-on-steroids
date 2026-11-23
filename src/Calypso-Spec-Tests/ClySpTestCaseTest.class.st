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

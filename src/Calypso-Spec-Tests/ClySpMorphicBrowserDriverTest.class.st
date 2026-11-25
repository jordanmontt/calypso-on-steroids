"
I check that the Morphic driver acts on the browser the way a user does: in the UI process, never concurrently with it.
"
Class {
	#name : 'ClySpMorphicBrowserDriverTest',
	#superclass : 'ClySpTestCase',
	#instVars : [
		'driver'
	],
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'running' }
ClySpMorphicBrowserDriverTest >> setUp [

	super setUp.
	driver := ClySpMorphicBrowserDriver new
]

{ #category : 'tests' }
ClySpMorphicBrowserDriverTest >> testRaisesInTheTestAnErrorOfABrowserAction [
	"A failing action must fail the test; in the UI process it would only open a debugger"

	self should: [ driver inUIProcess: [ 1 / 0 ] ] raise: ZeroDivide
]

{ #category : 'tests' }
ClySpMorphicBrowserDriverTest >> testRunsBrowserActionsInTheUIProcess [
	"Calypso updates its browsers in the Morphic UI process; acting from another process races with those updates. Without a UI, as in CI, UIManager default does not know that process."

	self assert: (driver inUIProcess: [ Processor activeProcess ]) identicalTo: MorphicUIManager uiProcess
]

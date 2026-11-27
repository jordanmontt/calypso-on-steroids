"
I check that the Morphic driver acts on the browser the way a user does: in the UI process, never concurrently with it.
"
Class {
	#name : 'ClySpMorphicBrowserDriverTest',
	#superclass : 'ClySpTestCase',
	#instVars : [
		'driver'
	],
	#category : 'Calypso-Spec-Tests-Morphic driver',
	#package : 'Calypso-Spec-Tests',
	#tag : 'Morphic driver'
}

{ #category : 'running' }
ClySpMorphicBrowserDriverTest >> setUp [

	super setUp.
	driver := ClySpMorphicBrowserDriver new
]

{ #category : 'tests' }
ClySpMorphicBrowserDriverTest >> testMakesSystemChangesInTheUIProcess [
	"The browser's editors update as soon as the system changes, in the process that changes it. If the test process made the change, the tabs would be rebuilt in that process while the UI process draws them. Both would change the same tabs at the same time, and the drawing would fail with index out of range."

	self assert: (driver changeSystemBy: [ Processor activeProcess ]) identicalTo: MorphicUIManager uiProcess
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

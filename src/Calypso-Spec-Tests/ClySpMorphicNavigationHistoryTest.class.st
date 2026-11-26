"
I run the navigation history tests on the Morphic browser.
"
Class {
	#name : 'ClySpMorphicNavigationHistoryTest',
	#superclass : 'ClySpNavigationHistoryTest',
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'running' }
ClySpMorphicNavigationHistoryTest >> expectedFailures [
	"Today's browser does not restore a tab clicked by hand when going back"

	^ #( #testAClickedTabIsAStep )
]

{ #category : 'running' }
ClySpMorphicNavigationHistoryTest >> newBrowserDriver [

	^ ClySpMorphicBrowserDriver new
]

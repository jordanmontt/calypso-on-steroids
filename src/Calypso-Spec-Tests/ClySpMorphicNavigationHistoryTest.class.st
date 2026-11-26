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
ClySpMorphicNavigationHistoryTest >> newBrowserDriver [

	^ ClySpMorphicBrowserDriver new
]

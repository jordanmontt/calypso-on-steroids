"
I run the tab tests on the Morphic browser.
"
Class {
	#name : 'ClySpMorphicTabsTest',
	#superclass : 'ClySpTabsTest',
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'running' }
ClySpMorphicTabsTest >> newBrowserDriver [

	^ ClySpMorphicBrowserDriver new
]

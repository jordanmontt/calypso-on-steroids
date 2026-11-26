"
I run the tab tests on the Morphic browser.
"
Class {
	#name : 'ClySpMorphicTabsTest',
	#superclass : 'ClySpTabsTest',
	#category : 'Calypso-Spec-Tests-Morphic driver',
	#package : 'Calypso-Spec-Tests',
	#tag : 'Morphic driver'
}

{ #category : 'running' }
ClySpMorphicTabsTest >> newBrowserDriver [

	^ ClySpMorphicBrowserDriver new
]

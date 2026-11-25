"
I run the selection tests on the Morphic browser.
"
Class {
	#name : 'ClySpMorphicSelectionTest',
	#superclass : 'ClySpSelectionTest',
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'running' }
ClySpMorphicSelectionTest >> newBrowserDriver [

	^ ClySpMorphicBrowserDriver new
]

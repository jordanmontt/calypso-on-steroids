"
I run the selection tests on the Morphic browser.
"
Class {
	#name : 'ClySpMorphicSelectionTest',
	#superclass : 'ClySpSelectionTest',
	#category : 'Calypso-Spec-Tests-Morphic driver',
	#package : 'Calypso-Spec-Tests',
	#tag : 'Morphic driver'
}

{ #category : 'running' }
ClySpMorphicSelectionTest >> newBrowserDriver [

	^ ClySpMorphicBrowserDriver new
]

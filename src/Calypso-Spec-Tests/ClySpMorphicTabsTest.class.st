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

{ #category : 'testing' }
ClySpMorphicTabsTest >> expectedFailures [
	"Today's browser drops the * of a dirty editor when it updates the editor"

	^ #( #testADirtyEditorStaysMarkedDirtyWhenItsClassIsRemoved )
]

{ #category : 'running' }
ClySpMorphicTabsTest >> newBrowserDriver [

	^ ClySpMorphicBrowserDriver new
]

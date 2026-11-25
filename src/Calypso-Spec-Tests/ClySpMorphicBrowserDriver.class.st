"
I drive the Morphic browser (ClyFullBrowserMorph) in the terms of a user, for the acceptance tests. I go through the browser API, which selects like a click does: a selection I make counts as the user's.
"
Class {
	#name : 'ClySpMorphicBrowserDriver',
	#superclass : 'Object',
	#instVars : [
		'browser'
	],
	#category : 'Calypso-Spec-Tests',
	#package : 'Calypso-Spec-Tests'
}

{ #category : 'opening' }
ClySpMorphicBrowserDriver >> close [

	browser ifNotNil: [ browser window close ]
]

{ #category : 'opening' }
ClySpMorphicBrowserDriver >> openOnClass: aClass [

	browser := ClyFullBrowserMorph openOnClass: aClass
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectClass: aClass [

	browser selectClass: aClass
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectMethod: aMethod [

	browser selectMethod: aMethod
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedMethods [

	^ browser methodSelection actualObjects
]

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

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectPackage: aPackage [

	browser selectPackage: aPackage
]

{ #category : 'selecting' }
ClySpMorphicBrowserDriver >> selectProtocolNamed: aString [

	browser selectMethodGroupNamed: aString
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedMethods [

	^ browser methodSelection actualObjects
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedPackages [

	^ browser packageSelection actualObjects
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> selectedProtocolNames [

	^ browser methodGroupSelection items collect: [ :each | each name ]
]

{ #category : 'reading' }
ClySpMorphicBrowserDriver >> shownMethods [

	^ browser methodView dataSource allElements collect: [ :each | each actualObject ]
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToClassSide [

	browser switchToMetaLevelScope: ClyClassSideScope
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToInstanceSide [

	browser switchToMetaLevelScope: ClyInstanceSideScope
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToPackages [

	browser switchToPackages
]

{ #category : 'switching' }
ClySpMorphicBrowserDriver >> switchToProjects [

	browser switchToProjects
]

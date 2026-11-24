"
I fail when the commands of Calypso no longer match the committed catalogue, and list the lines that changed. CI runs me weekly, apart from the build: Calypso changes in Pharo 15 builds on its own, and that must not break our build.
"
Class {
	#name : 'CosCommandCatalogueCheck',
	#superclass : 'TestCase',
	#category : 'CalypsoOnSteroids-Inventory-Tests',
	#package : 'CalypsoOnSteroids-Inventory-Tests'
}

{ #category : 'private' }
CosCommandCatalogueCheck >> changesFrom: committedLines to: currentLines [

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll:
				  'The commands of Calypso changed since the committed catalogue. Regenerate docs/features/command-catalogue.md as its last section says.';
			  lf.
		  (currentLines copyWithoutAll: committedLines) do: [ :each |
			  stream
				  nextPutAll: '+ ' , each;
				  lf ].
		  (committedLines copyWithoutAll: currentLines) do: [ :each |
			  stream
				  nextPutAll: '- ' , each;
				  lf ] ]
]

{ #category : 'tests' }
CosCommandCatalogueCheck >> testCommittedCatalogueMatchesTheImage [

	| committed current |
	committed := CosCommandCatalogue committedFile contents.
	current := CosCommandCatalogue ofImage markdown.
	self assert: committed = current description: [ self changesFrom: committed lines to: current lines ]
]

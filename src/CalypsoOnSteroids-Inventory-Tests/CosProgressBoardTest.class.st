"
I check the progress board written from small inventory and sheet texts, and that the committed board is up to date.
"
Class {
	#name : 'CosProgressBoardTest',
	#superclass : 'TestCase',
	#category : 'CalypsoOnSteroids-Inventory-Tests',
	#package : 'CalypsoOnSteroids-Inventory-Tests'
}

{ #category : 'running' }
CosProgressBoardTest >> inventory [

	^ String lf join: #( '| AAA-01 | One | notes | code | click | M |' '| AAA-02 | Two | notes | code | click | P |'
		     '| AAA-03 | Gone | notes | code | code | Dropped |' '| BBB-01 | Three | notes | code | code | X |' )
]

{ #category : 'running' }
CosProgressBoardTest >> markdown [

	^ (CosProgressBoard inventory: self inventory sheets: { ('AAA' -> self sheet) } asDictionary) markdown
]

{ #category : 'running' }
CosProgressBoardTest >> sheet [

	^ String lf join: #( '# AAA: test area' '' 'Status: **reviewed** 2026-11-24 (manual checks done). Code read on Pharo 15.'
		     '' '## AAA-01: One (M)' '' '**Scenarios.**' '- `AAA-01.a` Given one, then one → `CosProgressBoardTest>>testCountsScenariosAndTheirTestsPerFeature`'
		     '- `AAA-01.b` Given `x`, then two → `CosProgressBoardTest>>testThatDoesNotExist`'
		     '' '**Manual check.** None.' '' '## AAA-02: Two (P)' '' '- `AAA-02.a` Given two, then `y`'
		     '' '**Manual check.** Look at it. Checked 2026-11-24.' )
]

{ #category : 'tests' }
CosProgressBoardTest >> testADraftSheetIsShownAsDraft [

	| board |
	board := CosProgressBoard inventory: self inventory sheets: { ('AAA' -> '# AAA: test area') } asDictionary.
	self assert: (board markdown includesSubstring: '| AAA | 2 | 1 | 1 | 0 | draft | 0 | 0 | — |')
]

{ #category : 'tests' }
CosProgressBoardTest >> testATierWithANoteCountsAsItsTier [

	| board |
	board := CosProgressBoard inventory: '| CCC-01 | Four | notes | code | click | M (fix) |' sheets: Dictionary new.
	self assert: (board markdown includesSubstring: '| CCC | 1 | 1 | 0 | 0 |')
]

{ #category : 'tests' }
CosProgressBoardTest >> testAnAreaWithoutSheetHasNoScenarios [

	self assert: (self markdown includesSubstring: '| BBB | 1 | 0 | 0 | 1 | — | — | — | — |')
]

{ #category : 'tests' }
CosProgressBoardTest >> testCommittedBoardMatchesTheSheets [

	| page |
	page := CosProgressBoard committedFile contents.
	self assert: page equals: (CosProgressBoard ofCheckout progressPageFrom: page)
]

{ #category : 'tests' }
CosProgressBoardTest >> testCountsScenariosAndTheirTestsPerFeature [

	self assert: (self markdown includesSubstring: '| AAA-01 | M | 2 | 1 | — |')
]

{ #category : 'tests' }
CosProgressBoardTest >> testEndsLinesWithLineFeeds [

	self deny: (self markdown includes: Character cr)
]

{ #category : 'tests' }
CosProgressBoardTest >> testKeepsTheHandWrittenPartOfTheProgressPage [

	| board |
	board := CosProgressBoard inventory: self inventory sheets: Dictionary new.
	self
		assert: (board progressPageFrom: 'Intro' , String lf , String lf , '## Board' , String lf , 'old board')
		equals: 'Intro' , String lf , String lf , board markdown
]

{ #category : 'tests' }
CosProgressBoardTest >> testListsAreasWithTheirFeaturesByTier [

	self assert: (self markdown includesSubstring: '| AAA | 2 | 1 | 1 | 0 |')
]

{ #category : 'tests' }
CosProgressBoardTest >> testListsLinkedTestsThatDoNotExist [

	self assert: (self markdown includesSubstring: '- `CosProgressBoardTest>>testThatDoesNotExist` (AAA-01.b)')
]

{ #category : 'tests' }
CosProgressBoardTest >> testShowsADoneManualCheck [

	self assert: (self markdown includesSubstring: '| AAA-02 | P | 1 | 0 | done |')
]

{ #category : 'tests' }
CosProgressBoardTest >> testShowsAManualCheckToDo [

	| board |
	board := CosProgressBoard
		         inventory: self inventory
		         sheets: { ('AAA' -> (self sheet copyReplaceAll: ' Checked 2026-11-24.' with: '')) } asDictionary.
	self assert: (board markdown includesSubstring: '| AAA-02 | P | 1 | 0 | to do |')
]

{ #category : 'tests' }
CosProgressBoardTest >> testShowsWhenASheetWasReviewed [

	self assert: (self markdown includesSubstring: '| AAA | 2 | 1 | 1 | 0 | reviewed 2026-11-24 | 3 | 1 | 1 of 1 |')
]

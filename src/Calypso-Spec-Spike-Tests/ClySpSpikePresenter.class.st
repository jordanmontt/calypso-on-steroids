"
I am a tree of numbers with one command, Record, that remembers the selected item. ClySpSpecSpikeTest drives me.
"
Class {
	#name : 'ClySpSpikePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'tree',
		'recorded'
	],
	#category : 'Calypso-Spec-Spike-Tests',
	#package : 'Calypso-Spec-Spike-Tests'
}

{ #category : 'initialization' }
ClySpSpikePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: tree;
		  yourself
]

{ #category : 'initialization' }
ClySpSpikePresenter >> initialize [

	super initialize.
	recorded := OrderedCollection new
]

{ #category : 'initialization' }
ClySpSpikePresenter >> initializePresenters [

	tree := self newTreeTable
		        addColumn: (SpStringTableColumn title: 'Item' evaluated: [ :each | each printString ]);
		        roots: #( 1 2 );
		        children: [ :each |
			        each < 10
				        ifTrue: [
					        {
						        (each * 10 + 1).
						        (each * 10 + 2) } ]
				        ifFalse: [ #(  ) ] ];
		        actions: (CmCommandGroup forSpec
			         register: ((ClySpSpikeRecordCommand forSpecContext: self)
				          shortcutKey: $r meta;
				          yourself);
			         yourself);
		        yourself
]

{ #category : 'accessing' }
ClySpSpikePresenter >> record: anItem [

	recorded add: anItem
]

{ #category : 'accessing' }
ClySpSpikePresenter >> recorded [

	^ recorded
]

{ #category : 'accessing' }
ClySpSpikePresenter >> selectedItem [

	^ tree selectedItem
]

{ #category : 'accessing' }
ClySpSpikePresenter >> tree [

	^ tree
]

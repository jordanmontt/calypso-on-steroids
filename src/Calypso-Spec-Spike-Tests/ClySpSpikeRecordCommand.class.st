"
I make the ClySpSpikePresenter, my context, remember its selected item.
"
Class {
	#name : 'ClySpSpikeRecordCommand',
	#superclass : 'CmCommand',
	#category : 'Calypso-Spec-Spike-Tests',
	#package : 'Calypso-Spec-Spike-Tests'
}

{ #category : 'executing' }
ClySpSpikeRecordCommand >> execute [

	self context record: self context selectedItem
]

{ #category : 'initialization' }
ClySpSpikeRecordCommand >> initialize [

	super initialize.
	self name: 'Record'
]

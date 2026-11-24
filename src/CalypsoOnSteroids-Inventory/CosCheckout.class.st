"
I locate the checkout of this repository: the GitHub workspace on CI, the Iceberg repository otherwise.
"
Class {
	#name : 'CosCheckout',
	#superclass : 'Object',
	#category : 'CalypsoOnSteroids-Inventory',
	#package : 'CalypsoOnSteroids-Inventory'
}

{ #category : 'accessing' }
CosCheckout class >> root [

	^ (OSEnvironment current at: 'GITHUB_WORKSPACE' ifAbsent: [ nil ])
		  ifNil: [ (IceRepository registry detect: [ :each | each name = 'calypso-on-steroids' ]) location ]
		  ifNotNil: [ :path | path asFileReference ]
]

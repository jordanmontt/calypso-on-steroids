"
I stand for an Iceberg repository holding one package, for tests of what the browser offers on code under version control. I answer only whether I include a package: registered for the length of a test, nothing else of Iceberg reaches me.
"
Class {
	#name : 'ClySpIcebergRepositoryStub',
	#superclass : 'IceRepository',
	#instVars : [
		'packageName'
	],
	#category : 'Calypso-Spec-Tests-Support',
	#package : 'Calypso-Spec-Tests',
	#tag : 'Support'
}

{ #category : 'instance creation' }
ClySpIcebergRepositoryStub class >> including: aPackage [

	^ self basicNew setPackageName: aPackage name
]

{ #category : 'testing' }
ClySpIcebergRepositoryStub >> includesPackageNamed: aString [

	^ aString = packageName
]

{ #category : 'initialization' }
ClySpIcebergRepositoryStub >> setPackageName: aString [

	packageName := aString
]

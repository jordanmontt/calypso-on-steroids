"
I declare a few commands of each kind for CosCommandCatalogueTest. I am in a test package, so the catalogue of the image leaves me out.
"
Class {
	#name : 'CosCatalogueTestAnchor',
	#superclass : 'Object',
	#category : 'CalypsoOnSteroids-Inventory-Tests',
	#package : 'CalypsoOnSteroids-Inventory-Tests'
}

{ #category : 'commands' }
CosCatalogueTestAnchor class >> inventoryTestCommandsIn: aCommandMap [

	<calypsoCommands>
	(aCommandMap contextMenu add: SycFileOutClassCommand order: 20) group: SycClassExtraMenuGroup.
	(aCommandMap contextMenu add: SycCopyClassNameCommand order: 10) group: SycClassExtraMenuGroup.
	aCommandMap contextMenu add: ClyCloseBrowserCommand.
	(aCommandMap contextMenu add: ClySpawnFullBrowserCommand order: 10) group: ClyQueryMenuGroup.
	aCommandMap shortcuts add: ClyCloseBrowserCommand key: $w meta.
	aCommandMap doubleClick add: ClySpawnFullBrowserCommand.
	aCommandMap dragAndDrop add: ClyMoveClassToGroupCommand dropIn: ClyNoTagClassGroup.
	aCommandMap tabs add: ClyMethodCodeEditorToolMorph
]

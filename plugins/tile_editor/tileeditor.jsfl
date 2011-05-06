﻿fl.outputPanel.clear();//-----------------------------------// Library Document managment//-----------------------------------function newLibrary() {	var templateURI = fl.configURI + "WindowSWF/base_lib.fla";		var path = fl.browseForFolderURL();	if (path == null) return;	var filename = prompt("Library Filename");	if (filename == null) return;	var newFileURI = path + "/" + filename + ".fla";		FLfile.copy(templateURI, newFileURI);	var tDoc = fl.openDocument(newFileURI);	fl.setActiveWindow(tDoc);	setLibraryName(filename);}function getLibraryName() {	if (fl.documents.length == 0) {		return "null";	}	var dom = fl.getDocumentDOM();		return dom.getDataFromDocument("libraryName");}function setLibraryName(newLibraryName) {	var dom = fl.getDocumentDOM();		dom.addDataToDocument("libraryName", "string", String(newLibraryName));	cleanse_library();}function exportLibrary() {	var dom = fl.getDocumentDOM();	var library = dom.library;		cleanse_library();	// gather actionscript meta data from library assets	// LibraryID	var str = "var libraryID:String = \""+dom.getDataFromDocument("libraryName")+"\";\n";	// tiles Array	str += "var tiles:Array = [\n\t";	for (var i=0; i<library.items.length; i++) {		var tItem = library.items[i];		if (parseInt(tItem.getData("isTile")) == 1) {			var tID = tItem.getData("tileID");			var tRows = tItem.getData("rows");			var tCols = tItem.getData("cols");			var tHeight = tItem.getData("height");			str += "{tileID:\""+tID+"\", rows:"+tRows+", cols:"+tCols+", height:"+tHeight+", classRef:\""+tItem.linkageClassName+"\"}";			if (i < library.items.length-1) {				str += ", \n\t";			}		}	}	str += "\n];\n";	// bgImg Array	str += "var backgrounds:Array = [\n\t";	for (var i=0; i<library.items.length; i++) {		var tItem = library.items[i];		if (parseInt(tItem.getData("isBackground")) == 1) {			var tID = tItem.getData("backgroundID");			str += "{backgroundID:\""+tID+"\", classRef:"+tItem.linkageClassName+"\"}";			if (i < library.items.length-1) {				str += ", \n\t";			}		}	}	str += "\n];\n";	// store meta data to first frame of swf for export	var asFrame = fl.getDocumentDOM().timelines[0].layers[0].frames[0];	asFrame.actionScript = str;	dom.exportSWF();	asFrame.actionScript = ""; // cleanup}function importBackgroundImage() {	var dom = fl.getDocumentDOM();	var library = dom.library;		var fileURI = fl.browseForFileURL("select", "Import Background Bitmap");	if (fileURI == null) return;		dom.importFile(fileURI, true);	var tFilename = fileURI.substring(fileURI.lastIndexOf("/")+1, fileURI.length);		var libID = dom.getDataFromDocument("libraryName");	var tBmp = library.items[library.findItemIndex(tFilename)];		tBmp.name = tFilename.toLowerCase();	tBmp.linkageExportForAS = true;	tBmp.linkageExportInFirstFrame = true;	tBmp.linkageClassName = libID + "_" + tBmp.name;	// store persistent data in item	tBmp.addData("isBackground", "integer", Number(1));	tBmp.addData("backgroundID", "string", String(tBmp.name));}//-----------------------------------// Tile asset managment//-----------------------------------function createNewTile() {	var dom = fl.getDocumentDOM();	var library = dom.library;		dom.selectNone();	library.selectNone();	// jump to main timeline so tiles aren't created inside other tiles/symbols	dom.currentTimeline = 0;		// create the item in the library	var base_filename = "_basetile copy";	library.duplicateItem("_templates/_basetile");	library.moveToFolder("/", "_templates/"+base_filename, false);	var tItem = library.items[library.findItemIndex(base_filename)];	tItem.name = getUniqueTilename();	bless_tile(tItem);	// add item to stage for editing	var xpos = Math.ceil(dom.width * Math.random());	var ypos = Math.ceil(dom.height * Math.random());	// display on stage for editing	library.addItemToDocument({x:xpos, y:ypos}, tItem.name);}function bless_tile(tTile) {	var dom = fl.getDocumentDOM();	var libID = dom.getDataFromDocument("libraryName");	tTile.linkageExportForAS = true;	tTile.linkageExportInFirstFrame = true;	tTile.linkageClassName = libID + "_" + tTile.name;	tTile.linkageBaseClass = "flash.display.Sprite";	// store persistent data in item	tTile.addData("isTile", "integer", Number(1));	tTile.addData("tileID", "string", String(tTile.name));	tTile.addData("rows", "integer", Number(1));	tTile.addData("cols", "integer", Number(1));	tTile.addData("height", "integer", Number(0));}function updateTileID(newTileID) {	var dom = fl.getDocumentDOM();	var library = dom.library;		var libID = dom.getDataFromDocument("libraryName");	var className = libID + "_" + newTileID;	if (library.itemExists(newTileID)) {		alert("Tile name already in use.");		return;	}	if (dom.selection.length == 1) {		var tItem = dom.selection[0].libraryItem;		tItem.name = newTileID;		tItem.linkageClassName = className;		tItem.addData("tileID", "string", String(newTileID));			} else if (dom.selection.length > 1) {		alert("Too many items selected.  Only select one item to update.");	}}function updateTileValues(newRows, newCols, newHeight) {	var dom = fl.getDocumentDOM();		if (dom.selection.length == 1) {		var tItem = dom.selection[0].libraryItem;		tItem.addData("rows", "integer", Number(newRows));		tItem.addData("cols", "integer", Number(newCols));		tItem.addData("height", "integer", Number(newHeight));	} else if (dom.selection.length > 1) {		alert("Too many items selected.  Only select one item to update.");	}}function getUniqueTilename() {	var library = fl.getDocumentDOM().library;		var tileName = "newtile01";	var i=1;	while (library.itemExists(tileName)) {		tileName = "newtile" + (i<10) ? ("newtile0"+i) : ("newtile" + i);		i++;	}	return tileName;}//-----------------------------------// utility functions//-----------------------------------function cleanse_library() {	var dom = fl.getDocumentDOM();	var library = dom.library;		// updates all the library items names and classIDs in case any manual edits have been made.	if (library.items.length == 0) {		// no items to update		return;	}	for (var i=0; i<library.items.length; i++) {		var tItem = library.items[i];		if (tItem.hasData("isTile")) {			var tID = tItem.getData("tileID");			tItem.name = tID;			tItem.linkageClassName = dom.getDataFromDocument("libraryName") +"_"+ tID;		}	}}
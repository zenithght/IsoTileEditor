﻿package {		// stage instances:	// libraryIDStr:TextInput (component)	// tileIDStr:TextInput (component)	// rowInt:NumericStepper (component)	// colInt:NumericStepper (component)	// newTileBtn:Button (component)		import flash.ui.*;	import flash.display.*;	import flash.events.*;	import flash.external.ExternalInterface;	import adobe.utils.MMExecute; 	import flash.utils.Timer;	import fl.data.DataProvider;		public class TileBender extends MovieClip {				//private var _tileTypes:DataProvider = new DataProvider(["Sprite", "MovieClip", "SpriteSheet"]);				private var _libraryID:String;		private var _currentDoc:String = null;		private var _currentSelection:String = null;				private var _timer:Timer;				public function TileBender() {			//tileTypeCB.dataProvider = _tileTypes;						// library			libraryIDStr.addEventListener(KeyboardEvent.KEY_UP, onLibraryIDUpdate);			libraryIDStr.addEventListener(FocusEvent.FOCUS_OUT, onLibraryIDUpdate);			newLibraryBtn.addEventListener(MouseEvent.CLICK, onNewLibrary);			exportBtn.addEventListener(MouseEvent.CLICK, onExportLibrary);			bgImgBtn.addEventListener(MouseEvent.CLICK, onImportBackgroundImage);			// tile			tileIDStr.addEventListener(KeyboardEvent.KEY_UP, onTileIDChanged);			tileIDStr.addEventListener(FocusEvent.FOCUS_OUT, onTileIDChanged);			rowInt.addEventListener(Event.CHANGE, onPropsChanged);			colInt.addEventListener(Event.CHANGE, onPropsChanged);			heightStr.addEventListener(KeyboardEvent.KEY_UP, onPropsChanged);			interactiveCB.addEventListener(Event.CHANGE, onPropsChanged);			tileTypeCB.addEventListener(Event.CHANGE, onPropsChanged);						newTileBtn.addEventListener(MouseEvent.CLICK, onCreateNewTile);						libraryIDStr.tabIndex = 1;			tileIDStr.tabIndex = 2;			rowInt.tabIndex = 3;			colInt.tabIndex = 4;			heightStr.tabIndex = 5;			newLibraryBtn.tabEnabled = false;			exportBtn.tabEnabled = false;			bgImgBtn.tabEnabled = false;			newTileBtn.tabEnabled = false;			interactiveCB.tabEnabled = false;			tileTypeCB.tabEnabled = false;						addEventListener(Event.ADDED_TO_STAGE, init);		}				private function init(e:Event):void {			stage.align = StageAlign.TOP_LEFT;						_currentDoc = MMExecute("fl.runScript(fl.configURI + 'WindowSWF/stage_monitor.jsfl', 'getDocID');");			// set active if document is blessed, else inactive			updateDoc();			// init stage instance selection monitor			_timer = new Timer(500);			_timer.removeEventListener(TimerEvent.TIMER, monitorLoop);			_timer.addEventListener(TimerEvent.TIMER, monitorLoop);			_timer.start();						removeEventListener(Event.ADDED_TO_STAGE, init);		}				private function updateDoc():void {			var tName = MMexe("getLibraryName");			_libraryID = (tName == "0") ? "" : tName;						if (tName == "null" || tName == "0" || tName == "") {				_libraryID = "";				// disable UI elements				libraryIDStr.enabled = false;				exportBtn.enabled = false;				bgImgBtn.enabled = false;				tileIDStr.enabled = false;				newTileBtn.enabled = false;				rowInt.enabled = false;				colInt.enabled = false;				heightStr.enabled = false;				interactiveCB.enabled = false;				tileTypeCB.enabled = false;			} else {				_libraryID = tName;				// enable UI elements				libraryIDStr.enabled = true;				exportBtn.enabled = true;				bgImgBtn.enabled = true;				tileIDStr.enabled = true;				newTileBtn.enabled = true;				rowInt.enabled = true;				colInt.enabled = true;				heightStr.enabled = true;				interactiveCB.enabled = true;				tileTypeCB.enabled = true;			}			libraryIDStr.text = _libraryID;		}				private function onNewLibrary(e:Event):void {			MMexe("newLibrary");			updateDoc();		}		private function onExportLibrary(e:Event):void {			MMexe("exportLibrary");		}				private function onImportBackgroundImage(e:Event):void {			MMexe("importBackgroundImage");		}				private function monitorLoop(e:TimerEvent):void {			monitorStageSelection();			monitorDocSelection();		}				private function monitorStageSelection():void {			// monitors the stage for instance selection			// by querying jsfl since there's no native event			// returns: tileID, rows, cols, height, tileType			var props:Array = MMExecute("fl.runScript(fl.configURI + 'WindowSWF/stage_monitor.jsfl', 'getSelectionProps');").split(",");			if (props.length == 0) return;			if (props[0] != "" && props[0] != _currentSelection) {				// valid item selected				_currentSelection = props[0];				tileIDStr.text = props[0];				rowInt.value = Number(props[1]);				colInt.value = Number(props[2]);				heightStr.text = String(props[3]);				interactiveCB.selected = Number(props[4]) == 1 ? true : false;				for (var i=0; i<tileTypeCB.dataProvider.length; i++) {					var tItem = tileTypeCB.dataProvider.getItemAt(i);					if (tItem.data.toLowerCase() == props[5].toLowerCase()) {						tileTypeCB.selectedItem = tItem;					}				}			} else if (props[0] == "" && props[0] != _currentSelection) {				// nothing selected				_currentSelection = props[0];				tileIDStr.text = "";			}		}		private function monitorDocSelection():void {			// check for current document focus			var tDoc:String = MMExecute("fl.runScript(fl.configURI + 'WindowSWF/stage_monitor.jsfl', 'getDocID');");			if (tDoc != _currentDoc) {				_currentDoc = tDoc;				updateDoc();			}		}				private function onCreateNewTile(e:MouseEvent):void {			MMexe("createNewTile");		}				private function onLibraryIDUpdate(e):void {			if (libraryIDStr.text != _libraryID) {				if (e.type == "keyUp" && e.keyCode == Keyboard.ENTER) {					MMexe("setLibraryName", libraryIDStr.text);				} else if (e.type == "focusOut") {					MMexe("setLibraryName", libraryIDStr.text);				}			}		}				private function onTileIDChanged(e):void {			if (tileIDStr.text != _currentSelection) {				if (e.type == "keyUp" && e.keyCode == Keyboard.ENTER) {					MMexe("updateTileID", tileIDStr.text);				} else if (e.type == "focusOut") {					MMexe("updateTileID", tileIDStr.text);				}			}		}		private function onPropsChanged(e:Event):void {			trace(tileTypeCB.selectedItem.data)			MMexe("updateTileValues", rowInt.value, colInt.value, int(heightStr.text), interactiveCB.selected == true ? 1 : 0, tileTypeCB.selectedItem.label);		}				// utility for calling MMExecute functions		private function MMexe(funcStr:String, ... rest):String {			// build arguments string if needed			var args:String = (rest.length > 0) ? (",'"+rest.join("','")+"'") : "";			return MMExecute("fl.runScript(fl.configURI + 'WindowSWF/tileeditor.jsfl', '"+funcStr+"'"+args+");");		}	}}
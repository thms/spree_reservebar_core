
	var sleepCounter = 0;

	function findPrinters() {
		var applet = document.jZebra;
		if (applet != null) {
			// Searches for locally installed printer by name
			// Pass in printer name from dialog, since each retailer has different printers and the printer depends on the 
			// type of item to print
			applet.findPrinter($("#jzebra_dialog").attr("printer"));
		}
		monitorFinding2();
	}

	/* Item can be a gift message or a shipping label */
	function printItem() {
 		var applet = document.jZebra;
		if (applet != null) {
			$("#progress").slideDown();
			applet.findPrinter($("#printerList option:selected").text());
			appendItem();
		}
	}

	function appendItem() {
		var applet = document.jZebra;
		if (applet != null) {
			if (!applet.isDoneFinding()) {
	      		window.setTimeout('appendItem()', 100);
	   		} else {
				if ($("#jzebra_dialog").attr("format") == 'raw') {
     				applet.appendFile($("#jzebra_dialog").attr("url"));
				} 
				else if ($("#jzebra_dialog").attr("format") == 'html') {
	     			applet.appendHTMLFile($("#jzebra_dialog").attr("url"));
				}
				else {
					applet.appendPDF($("#jzebra_dialog").attr("url"));
				}
				//wait for appending to finish before attempting to print: (monitorAppending will print when ready)
          		monitorAppending();
			}
		}
	}

/* Notifications from 1.4.3 version of applet */
/* Not yet used in this version of the code */
function jzebraReady() {}
function jzebraDoneAppending() { }
function jzebraDoneFinding() { }
function jzebraDonePrinting() { }

// Automatically gets called when the applet is done printing
function jzebraDonePrinting() { }

/* Generric functions */
    
	function chr(i) {
		return String.fromCharCode(i);
	}
    
    
 	function monitorPrinting() {
		$("#progress").slideUp();
		alert("Label sent to printer ...");
		hidePrintDialog();
	}
    
    /**
     * Monitors the Java applet until it is complete with the specified function
     *    appletFunction:  should return a "true" or "false"
     *    finishedFunction:  will be called if the function completes without error
     *    description:  optional description for errors, etc
     *
     * Example:
     *    monitorApplet('isDoneFinding()', 'alert(\\"Success\\")', '');
     */
    function monitorApplet(appletFunction, finishedFunction, description) {
    	var NOT_LOADED = "jZebra hasn't loaded yet.";
    	var INVALID_FUNCTION = 'jZebra does not recognize function: "' + appletFunction; + '"';
    	var INVALID_PRINTER = "jZebra could not find the specified printer";
    	if (document.jZebra != null) {
    		var finished = false;
    		try {
    		   finished = eval('document.jZebra.' + appletFunction);
    		} catch (err) {
    		   alert('jZebra Exception:  ' + INVALID_FUNCTION);
    		   return;
    		}
	   if (!finished) {
	      window.setTimeout('monitorApplet("' + appletFunction + '", "' + 
	      	      finishedFunction.replace(/\"/g,'\\"') + '", "' + description + '")', 100);
	   } else {
	   	var p = document.jZebra.getPrinterName();
	   	if (p == null) {
	   		alert("jZebra Exception:  " + INVALID_PRINTER);
	   		return;
	   	}
		var e = document.jZebra.getException();
	      	if (e != null) {
	      		var desc = description == "" ? "" : " [" + description + "] ";
	      		alert("jZebra Exception: " + desc + document.jZebra.getExceptionMessage());
	      		document.jZebra.clearException();
	   	} else {
	   		eval(finishedFunction);
	   	}
	   }
	} else {
	   alert("jZebra Exception:  " + NOT_LOADED);
	}
    }
        
 
 
    function monitorFinding2() {
	var applet = document.jZebra;
	if (applet != null) {
	   if (!applet.isDoneFinding()) {
	      window.setTimeout('monitorFinding2()', 100);
	   } else {
	   	   var listing = applet.getPrinters();
	   	   var printers = listing.split(',');
	   	   for(var i in printers){
	   	   	   document.getElementById("printerList").options[i]=new Option(printers[i]);
           }
	   }
	} else {
          alert("Applet not loaded!");
      }
    }
    
    function monitorAppending() {
	var applet = document.jZebra;
	if (applet != null) {
	   if (!applet.isDoneAppending()) {
	      window.setTimeout('monitorAppending()', 100);
	   } else {
			if ($("#jzebra_dialog").attr("format") == 'raw') {
	      		applet.print(); // Don't print until all of the data has been appended
			} 
			else if ($("#jzebra_dialog").attr("format") == 'html') {
				applet.printHTML();
			}
			else {
				applet.printPS(); // PDF documents use printPS function
			}
          	monitorPrinting();
	   }
	} else {
          alert("Applet not loaded!");
      }
    }   
 

	function monitorLoading() {
		var applet = document.jZebra;
		if (document.jZebra != null) {
			try {
				if (document.jZebra.isActive()) {
					document.getElementById("version").innerHTML = "<strong>Status:</strong>  jZebra " + applet.getVersion() + " loaded.";
				}
			} catch (err) {
				// Firefox fix
				window.setTimeout("monitorLoading()", 500);
			}  
		} else {
			window.setTimeout("monitorLoading()", 100);
		}
	}

	function monitorLoadingThenCall(doneFunc) {
		var applet = document.jZebra;
		if (document.jZebra != null) {
			try {
				if (document.jZebra.isActive()) {
					document.getElementById("version").innerHTML = "<strong>Status:</strong>  jZebra " + applet.getVersion() + " loaded.";
					eval(doneFunc);
				}
			} catch (err) {
				// Firefox fix
				doneFunc =  "'" + doneFunc.replace(/\"/g,'\\"') + "'";
				window.setTimeout("monitorLoadingThenCall(" + doneFunc + ")", 500);
			}  
		} else {
		doneFunc =  "'" + doneFunc.replace(/\"/g,'\\"') + "'";
			window.setTimeout("monitorLoadingThenCall(" + doneFunc + ")", 100);
		}
	}


	/* format is 'raw','pdf' */
	function showPrintDialog(shipment_number, label_url, format, printer) {
		$("#jzebra_dialog").param
		$("#jzebra_shipment").html(shipment_number);
		$("#jzebra_dialog").attr("url", label_url);
		$("#jzebra_dialog").attr("format", format);
		$("#jzebra_dialog").attr("printer", printer);
		$("#jzebra_dialog").show();
		if (format == 'raw') {
			$("#jzebra_shipment_row").show();
		} else {
			$("#jzebra_gift_message_row").show();
		}
		monitorLoadingThenCall("findPrinters()");
	}
	
	function hidePrintDialog() {
		$("#jzebra_dialog").hide();
	}


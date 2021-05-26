s=File.separator;

Dialog.create("Recursive Batch Processing Template");
Dialog.addCheckbox("Input Directory = Output Directory", true);
Dialog.addMessage("Recursive Batch Processing of files that end with:");
items=newArray("_C2_Reg", "_C2toC1_Reg_C2_Spl");
Dialog.addString("Specify input Identifier:", ".tif");
Dialog.addMessage("Label outputfiles with:");
Dialog.addString("Specify output Identifier:", "_new.tif");

Dialog.show();

inDisOutD=Dialog.getCheckbox();
RecBatchProc=Dialog.getChoice();
InIdentifier=Dialog.getString();
OutIdentifier=Dialog.getString();

inDir=getDirectory("Choose the Raw Data Containing Folder");

if (inDisOutD==true) {
	outDir=inDir;
}
else {
	outDir=getDirectory("Choose Output Folder");
	if ((inDir==outDir) || (startsWith(outDir, inDir))) {
	exit("Input folder must be different from and not within output folder!");
	}
}

//setBatchMode(true);

if (RecBatchProc==true) {
	RecursiveBatchProcessing(inDir, outDir);
}

//setBatchMode(false);


function RecursiveBatchProcessing(inDir, outDir) {
	list = getFileList(inDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/")) {
			RecursiveBatchProcessing(inDir+list[i], outDir+list[i]);
		}
		else if ((endsWith(list[i], InIdentifier))&&(!File.exists(replace(outDir+s+list[i], InIdentifier, OutIdentifier)))) {
		//Enter your custon processing steps here.
		//Use macro recorder to record your custom workflow.
		//Also, do not forget do adapt file saving.
		saveAs("tiff", replace(outDir+s+list[i], InIdentifier, OutIdentifier));
		}
	}
}
print("Done");

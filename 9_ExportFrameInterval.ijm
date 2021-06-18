s=File.separator;

Dialog.create("Recursive Batch Processing Template");
Dialog.addCheckbox("Input Directory = Output Directory", true);
Dialog.addMessage("Recursive Batch Processing of files that end with:");
Dialog.addString("Specify input Identifier:", "_Stack_Extr.tif");
Dialog.addMessage("Label outputfiles with:");
Dialog.addString("Specify output Identifier:", "_FrameInterval.csv");

Dialog.show();

inDisOutD=Dialog.getCheckbox();

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

setBatchMode(true);

RecursiveBatchProcessing(inDir, outDir);

print("Done");

setBatchMode(false);


function RecursiveBatchProcessing(inDir, outDir) {
	list = getFileList(inDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/")) {
			RecursiveBatchProcessing(inDir+list[i], outDir+list[i]);
		}
		else if ((endsWith(list[i], InIdentifier))&&(!File.exists(replace(outDir+s+list[i], InIdentifier, OutIdentifier)))) {
		open(inDir+list[i]);
		name=File.getName(inDir+list[i]);
		selectWindow(name);
		FrameInterval=Stack.getFrameInterval();
		print(FrameInterval);
		selectWindow("Log");
		saveAs("Text", replace(outDir+s+list[i], InIdentifier, OutIdentifier));
		close("Log");
		close(name);
		}
	}
}


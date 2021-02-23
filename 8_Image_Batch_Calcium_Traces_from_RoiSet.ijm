s=File.separator;

Dialog.create("Bruker Data Manager");
Dialog.addCheckbox("Input Directory = Output Directory", true);
Dialog.addMessage("Extract Mean Gray Values from ROI:");
items=newArray("_C2_Reg", "_C2toC1_Reg_C2_Spl", "_BSub");
Dialog.addChoice("Extract From:", items, "_BSub");
Dialog.addMessage("Delete Files:");

Dialog.show();

inDisOutD=Dialog.getCheckbox();
ExtrFrom=Dialog.getChoice();

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
MeanGrayValueExtraction(inDir, outDir);
setBatchMode(false);

function MeanGrayValueExtraction(inDir, outDir) {
	run("Set Measurements...", "mean redirect=None decimal=3");
	list = getFileList(inDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/")) {
			MeanGrayValueExtraction(inDir+list[i], outDir+list[i]);	
		}
		else if ((endsWith(list[i], ExtrFrom+".tif"))&&(!File.exists(replace(outDir+s+list[i], ExtrFrom+".tif", ExtrFrom+"_MeanGray.csv")))) {
			open(outDir+list[i]);
			name=File.getName(outDir+list[i]);
			selectWindow(name);
			roiManager("Open", replace(outDir+s+list[i], ExtrFrom+".tif", "_RoiSet.zip"));
			roiManager("Select", 0);
			roiManager("Multi Measure");
			selectWindow("Results");
			saveAs("Results", replace(outDir+s+list[i], ExtrFrom+".tif", ExtrFrom+"_MeanGray.csv"));
			close("Results");
			roiManager("Select", 0);
			roiManager("Delete");
			roiManager("Select", 0);
			roiManager("Delete");
			close(name);
			run("Close All");
		}
	}
}

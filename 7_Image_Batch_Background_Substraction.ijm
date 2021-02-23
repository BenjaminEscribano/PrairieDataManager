s=File.separator;

Dialog.create("Bruker Data Manager");
Dialog.addCheckbox("Input Directory = Output Directory", true);
Dialog.addMessage("Substract Background From:");
items=newArray("_SReg", "_C1_Reg", "_C2_Reg", "_C2toC1_Reg_C2_Spl", "_C1toC2_Reg_C2_Spl");
Dialog.addChoice("Extract From:", items, "C1_Reg.tif");

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
BackgroundSubtraction(inDir, outDir);
setBatchMode(false);

function BackgroundSubtraction(inDir, outDir) {
	run("Set Measurements...", "mean redirect=None decimal=3");
	list = getFileList(inDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/")) {
			BackgroundSubtraction(inDir+list[i], outDir+list[i]);
		}
		else if ((endsWith(list[i], ExtrFrom+".tif"))&&(!File.exists(replace(outDir+s+list[i], ExtrFrom+".tif", ExtrFrom+"_BSub.tif")))) {
			open(outDir+list[i]);
			name=File.getName(outDir+list[i]);
			selectWindow(name);
			N=nSlices;
			roiManager("Open", replace(outDir+s+list[i], ExtrFrom+".tif", ExtrFrom+"_RoiSet.zip"));
			roiManager("Select", 1);
			roiManager("Multi Measure");
			roiManager("Delete");
			selectWindow(name);
			for (k=1; k<=N; k++) {
				Background=getResult("Mean(Background)", k-1);
				Stack.setSlice(k);
				run("Subtract...", "value="+Background+" slice");
				}
			roiManager("Delete");
			selectWindow(name);
			saveAs("Tiff", replace(outDir+s+list[i], ExtrFrom+".tif", ExtrFrom+"_BSub.tif"));
			close(name);
			close("Results");
			run("Close");
			run("Close All");
		}
	}
}
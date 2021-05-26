s=File.separator;

Dialog.create("Bruker Data Manager");
Dialog.addCheckbox("Input Directory = Output Directory", true);
Dialog.addMessage("Extract Mean Gray Values from ROI:");
items=newArray("_SReg", "_C1_Reg", "_C2_Reg", "_C2toC1_Reg", "_C1toC2_Reg");
Dialog.addChoice("Extract From:", items, "C1_Reg.tif");
items1=newArray("Maximum Intensity", "Average Intensity");
Dialog.addChoice("Projection for ROI:", items1, "Average Intensity");

Dialog.show();

inDisOutD=Dialog.getCheckbox();
ExtrFrom=Dialog.getChoice();
Projection=Dialog.getChoice();

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

SingleCellSegmentation(inDir, outDir);

function SingleCellSegmentation(inDir, outDir) {
	list = getFileList(inDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/")) {
			SingleCellSegmentation(inDir+list[i], outDir+list[i]);
		}
		else if ((endsWith(list[i], ExtrFrom+".tif"))&&(!File.exists(replace(outDir+s+list[i], ExtrFrom+".tif", ExtrFrom+"_RoiSet.zip")))) {
			open(outDir+list[i]);
			name=File.getName(outDir+list[i]);
			selectWindow(name);
			run("Z Project...", "projection=["+Projection+"]");
			selectWindow("AVG_"+name);
			run("Duplicate...", "title=Mask");
			selectWindow("Mask");
			run("Make Binary");
			setTool("wand");
			run("ROI Manager...");
			waitForUser("Select the Cell/ROI please");
			roiManager("Add");
			roiManager("Select", 0);
			roiManager("Rename", "Cell");
			run("Make Inverse");
			roiManager("Add");
			roiManager("Select", 1);
			roiManager("Rename", "Background");
			roiManager("Select", newArray(0,1));
			roiManager("Save", replace(outDir+s+list[i], ExtrFrom+".tif", ExtrFrom+"_RoiSet.zip"));
			selectWindow(name);
			close(name);
			close("Results");
			roiManager("Select", newArray(0,1));
			roiManager("Delete");
			run("Close");
			run("Close All");
		}
	}
}
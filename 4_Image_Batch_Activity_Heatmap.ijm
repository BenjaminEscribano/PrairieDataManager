s=File.separator;

Dialog.create("Bruker Data Manager");
Dialog.addCheckbox("Input Directory = Output Directory", true);
Dialog.addMessage("Normalized Fluorescence Change:");
Dialog.addCheckbox("Generate DeltaF/F0", true);
Dialog.addToSameRow();
items=newArray("_C2_Reg", "_C2toC1_Reg_C2_Spl");
Dialog.addChoice("", items, "C1_Reg.tif");
Dialog.addSlider("F0 Start Slice", 1, 9999, 1);
Dialog.addSlider("F0 Stop Slice", 1, 9999, 100);
Dialog.addCheckbox("Generate Heatmap", true);

Dialog.show();

inDisOutD=Dialog.getCheckbox();
GenDelta=Dialog.getCheckbox();
DeltaChoice=Dialog.getChoice();
FStart=Dialog.getNumber();
FStop=Dialog.getNumber();
Heatmap=Dialog.getCheckbox();

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
if (GenDelta==true) {
	NormalizedFluorescenceChangeStack(inDir, outDir);
}
print("Done");
setBatchMode(false);

function NormalizedFluorescenceChangeStack(inDir, outDir) {
	list = getFileList(inDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/")) {
			NormalizedFluorescenceChangeStack(inDir+list[i], outDir+list[i]);	
		}
		else if ((endsWith(list[i], DeltaChoice+".tif"))&&(!File.exists(replace(outDir+s+list[i], DeltaChoice, DeltaChoice+"_DeltaF.tif")))) {
			open(outDir+list[i]);
			name=File.getName(outDir+list[i]);
			selectWindow(name);
			run("Z Project...", "start="+FStart+" stop="+FStop+" projection=[Average Intensity]");
			imageCalculator("Subtract create stack", name,"AVG_"+name);
			close(name);
			imageCalculator("Divide create stack", "Result of "+name,"AVG_"+name);
			if (Heatmap==true) {
			selectWindow("Result of Result of "+name);
			run("Z Project...", "projection=[Sum Slices]");
			selectWindow("SUM_Result of Result of "+name);
			run("16_colors");
			saveAs("tiff", replace(outDir+s+list[i], DeltaChoice, DeltaChoice+"_DeltaFHeatMap"));
			}
		selectWindow("Result of Result of "+name);
		saveAs("tiff", replace(outDir+s+list[i], DeltaChoice, DeltaChoice+"_DeltaF"));
		run("Close All");
		}
	}
}

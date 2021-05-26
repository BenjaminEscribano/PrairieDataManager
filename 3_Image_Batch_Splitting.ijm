s=File.separator;

Dialog.create("Bruker Data Manager");
Dialog.addCheckbox("Input Directory = Output Directory", true);
Dialog.addMessage("Channel Splitting:");
Dialog.addCheckbox("Split Channels and Keep:", true);
Dialog.addToSameRow();
items=newArray("Stack_Extr", "C2toC1_Reg", "C1toC2_Reg");
Dialog.addChoice("", items, "C1_Reg.tif");
items = newArray("C1", "C2");
Dialog.addRadioButtonGroup("", items, 1, 2, "C2");

Dialog.show();

inDisOutD=Dialog.getCheckbox();
ChSplitKeep=Dialog.getCheckbox();
ChSplitKeepChoice=Dialog.getChoice();
Keep=Dialog.getRadioButton();

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
if (ChSplitKeep==true) {
	SplitChannelsAndKeep(inDir, outDir);
}
print("Done");
setBatchMode(false);

function SplitChannelsAndKeep(inDir, outDir) {
	list = getFileList(inDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/")) {
			SplitChannelsAndKeep(inDir+list[i], outDir+list[i]);	
		}
		else if ((endsWith(list[i], ChSplitKeepChoice+".tif"))&&(!File.exists(replace(outDir+s+list[i], ChSplitKeepChoice, ChSplitKeepChoice+"_"+Keep+"_Spl.tif")))) {
			open(outDir+list[i]);
			name=File.getName(outDir+list[i]);
			selectWindow(name);
			run("Split Channels");
			selectWindow(Keep+"-"+name);
			saveAs("tiff", replace(outDir+s+list[i], ChSplitKeepChoice, ChSplitKeepChoice+"_"+Keep+"_Spl"));
			run("Close All");	
		}
	}
}


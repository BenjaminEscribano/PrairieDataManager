s=File.separator;

Dialog.create("Bruker Data Manager");
Dialog.addCheckbox("Input Directory = Output Directory", false);
Dialog.addMessage("Image Extraction from Raw Data:");
Dialog.addCheckbox("Extract Files from RAW Data", true);
Dialog.addMessage("(Make sure there are no RAWDATA Folders!)");
Dialog.show();

inDisOutDir=Dialog.getCheckbox();
Extr=Dialog.getCheckbox();

inDir=getDirectory("Choose the Raw Data Containing Folder");

if (inDisOutDir==true) {
	outDir=inDir;
}
else {
	outDir=getDirectory("Choose Output Folder");
	if ((inDir==outDir) || (startsWith(outDir, inDir))) {
		exit("Input folder must be different from and not within output folder!");
	}
}

setBatchMode(true);
if (Extr==true) {
	ExtractFiles(inDir,outDir);
	print("Done!");
}
setBatchMode(false);

function ExtractFiles(inDir,outDir) {
	list = getFileList(inDir);
	for (i=0; i<list.length; i++)     {
		if (endsWith(list[i], "/")) {
			DuplicatePath=replace(inDir+s+list[i], inDir, outDir);
			if (!File.exists(DuplicatePath) && !endsWith(DuplicatePath, "MIP/") && !endsWith(DuplicatePath, "References/")) {
				File.makeDirectory(DuplicatePath);
     		}
			ExtractFiles(inDir+list[i],outDir+list[i]);
     	}
		else if (endsWith(list[i], ".xml"))	{
			ExtractedFilePath=replace(inDir+s+list[i], inDir, outDir);
			//For windows users the .xml format can not be used. They have to use the import image sequence function
			ExtractedFile=replace(ExtractedFilePath, ".xml", "_Stack_Extr.tif");
			if (!File.exists(ExtractedFile)) {
				run("Bio-Formats", "open=["+inDir+list[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
				name=File.getName(outDir+list[i]);
				selectWindow(name);
				sln=nSlices;
				if (sln>1) {
					Stack.setChannel(1);
					resetMinAndMax();
					Stack.setChannel(2);
					resetMinAndMax();
					saveAs("tiff", replace(ExtractedFilePath, ".xml", "_Stack_Extr.tif"));
				}
				else   {
					saveAs("tiff", replace(ExtractedFilePath, ".xml", "_Extr.tif"));  			
				}   			
				run("Close All");
				run("Collect Garbage");
				close("Log");
			}
		}
	}
}
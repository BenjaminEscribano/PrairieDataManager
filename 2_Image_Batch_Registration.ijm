s=File.separator

Dialog.create("Bruker Data Manager");
Dialog.addCheckbox("Input Directory = Output Directory", true);
Dialog.addMessage("Image Registration (1 Channel Images):");
Dialog.addCheckbox("Single Channel Image Registration", false);
Dialog.addMessage("Image Registration (2 Channel Images):");
Dialog.addCheckbox("Ch2 (Green) Only Registration", false);
Dialog.addCheckbox("Ch1 (Red) Only Registration", false);
Dialog.addCheckbox("Ch2 to Ch1 Channel Registration", false);
Dialog.addCheckbox("Ch1 to Ch2 Channel Registration", false);
items = newArray("AVG Complete", "AVG Selection");
Dialog.addRadioButtonGroup("", items, 1, 2, "AVG Complete");
Dialog.addSlider("Start Slice", 1, 9999, 1);
Dialog.addSlider("Stop Slice", 1, 9999, 9999);

Dialog.show();

inDisOutD=Dialog.getCheckbox();
SChReg=Dialog.getCheckbox();
GReg=Dialog.getCheckbox();
RReg=Dialog.getCheckbox();
C2toC1=Dialog.getCheckbox();
C1toC2=Dialog.getCheckbox();
AVG=Dialog.getRadioButton();
AVGStart=Dialog.getNumber();
AVGStop=Dialog.getNumber();

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

if (SChReg==true) {
	SingleChannelImageRegistration(inDir, outDir);
}
if (GReg==true) {
	source1="C2";
	source2="C1";
	target1="C2";
	target2="C1";
	RegisterFilesChannelABOnly(inDir, outDir);
}
if (RReg==true) {
	source1="C1";
	source2="C2";
	target1="C1";
	target2="C2";
	RegisterFilesChannelABOnly(inDir, outDir);
}
if (C2toC1==true) {
	source1="C1";
	source2="C2";
	target1="C1";
	target2="C2";
	RegisterFilesChannelAToChannelB(inDir, outDir);
}
if (C1toC2==true) {
	source1="C2";
	source2="C1";
	target1="C2";
	target2="C1";
	RegisterFilesChannelAToChannelB(inDir, outDir);
}

print("Done");

setBatchMode(false);

function SingleChannelImageRegistration(inDir, outDir) {
	list = getFileList(inDir);
	for (i=0; i<list.length; i++)     {
		if (endsWith(list[i], "/")) {
			DuplicatePath=replace(inDir+s+list[i], inDir, outDir);
			if (!File.exists(DuplicatePath)) {
				File.makeDirectory(DuplicatePath);
			}
			SingleChannelImageRegistration(inDir+list[i],outDir+list[i]);
		}
		else if ((endsWith(list[i], "_Stack_Extr.tif"))&&(!File.exists(replace(outDir+s+list[i],"_Stack_Extr.tif", "_SReg.tif"))))	{
			DestinationFilePath=replace(inDir+s+list[i], inDir, outDir);
			open(inDir+list[i]);
			name=File.getName(inDir+list[i]);
			selectWindow(name);
			width=getWidth();
			height=getHeight();
			rename("source");
			if (AVG=="AVG Complete") {
				run("Z Project...", "projection=[Average Intensity]");
			}
			else if (AVG=="AVG Selection") {
				run("Z Project...", "start="+AVGStart+" stop="+AVGStop+" projection=[Average Intensity]");
			}
			selectWindow("AVG_source");
			rename("target");
			selectWindow("source");
			sln=nSlices;
			for(k=1; k <=sln; k++) {
				selectWindow("source");
				setSlice(k);
				run("Duplicate...", "title=currentFrame");
				run("TurboReg ", "-align -window currentFrame 0 0 "+(width - 1)+" " +(height - 1)+" "+"-window target 0 0 "+(width - 1)+" "+(height - 1)+" -rigidBody "+(width / 2)+" "+(height / 2)+" "+(width / 2)+" "+(height / 2)+" "+"0 " + (height / 2)+" 0 "+(height / 2)+" "+(width - 1)+" "+(height / 2)+" "+(width - 1)+" "+(height / 2)+" -showOutput");
				selectWindow("Output");
				rename("outputimg");
				run("Duplicate...", "title=registered");
				if(k==1) {
					run("Duplicate...", "title=" + "regstack");
					selectWindow("registered");
					close();
				}
				else {
					run("Concatenate...", "  title=" + "regstack" + " image1=" + "regstack" + " image2=registered image3=[-- None --] image4=[-- None --]");
				}
				selectWindow("outputimg");
				close();
				selectWindow("currentFrame");
				close();
			}
			selectWindow("regstack");
			run("16-bit");
			saveAs("tiff", replace(DestinationFilePath, "_Stack_Extr.tif", "_SReg.tif"));
			run("Close All");
			close("Refined Landmarks");
			run("Collect Garbage");
			close("Log");
		}
	}
}

function RegisterFilesChannelABOnly(inDir, outDir) {
	list = getFileList(inDir);
	for (i=0; i<list.length; i++)     {
		if (endsWith(list[i], "/")) {
			DuplicatePath=replace(inDir+s+list[i], inDir, outDir);
			if (!File.exists(DuplicatePath)) {
				File.makeDirectory(DuplicatePath);
			}
			RegisterFilesChannelABOnly(inDir+list[i],outDir+list[i]);
		}
		else if ((endsWith(list[i], "_Stack_Extr.tif"))&&(!File.exists(replace(outDir+s+list[i],"_Stack_Extr.tif", "_"+source1+"_Reg.tif"))))	{
			DestinationFilePath=replace(inDir+s+list[i], inDir, outDir);
			open(inDir+list[i]);
			name=File.getName(inDir+list[i]);
			selectWindow(name);			
			width=getWidth();
			height=getHeight();
			rename("source");
			if (AVG=="AVG Complete") {
				run("Z Project...", "projection=[Average Intensity]");
			}
			else if (AVG=="AVG Selection") {
				run("Z Project...", "start="+AVGStart+" stop="+AVGStop+" projection=[Average Intensity]");
			}
			selectWindow("AVG_source");
			rename("target");
			run("Split Channels");
			close(target2+"-target");
			selectWindow("source");
			run("Split Channels");
			sln=nSlices;
			close(source2+"-source");
			for(k=1; k <=sln; k++) {
				selectWindow(source1+"-source");
				setSlice(k);
				run("Duplicate...", "title=currentFrame");
				run("TurboReg ", "-align "+"-window currentFrame 0 0 "+(width - 1)+" " +(height - 1)+" "+"-window "+target1+"-target 0 0 "+(width - 1)+" "+(height - 1) +" -rigidBody "+(width / 2)+" "+(height / 2)+" "+ (width / 2) + " " + (height / 2) + " "+ "0 " + (height / 2) + " 0 "+(height / 2)+" "+(width - 1)+" "+(height / 2)+" "+(width - 1)+" "+(height / 2)+" -showOutput");
				selectWindow("Output");
				rename("outputimg");
				run("Duplicate...", "title=registered");
				if(k==1) {
					run("Duplicate...", "title=" + "regstack");
					selectWindow("registered");
					close();
				}
				else {
					run("Concatenate...", "  title=" + "regstack" + " image1=" + "regstack" + " image2=registered image3=[-- None --] image4=[-- None --]");
				}
				selectWindow("outputimg");
				close();
				selectWindow("currentFrame");
				close();
			}
			selectWindow("regstack");
			resetMinAndMax();
			run("16-bit");
			saveAs("tiff", replace(DestinationFilePath, "_Stack_Extr.tif", "_"+source1+"_Reg.tif"));
			run("Close All");
			close("Refined Landmarks");	
			run("Collect Garbage");
			close("Log");			   		
		}
	}
}

function RegisterFilesChannelAToChannelB(inDir, outDir) {
	list = getFileList(inDir);
	for (i=0; i<list.length; i++)     {
		if (endsWith(list[i], "/")) {
			DuplicatePath=replace(inDir+s+list[i], inDir, outDir);
			if (!File.exists(DuplicatePath)) {
				File.makeDirectory(DuplicatePath);
			}
			RegisterFilesChannelAToChannelB(inDir+list[i],outDir+list[i]);
		}
		else if ((endsWith(list[i], "_Stack_Extr.tif"))&&(!File.exists(replace(outDir+s+list[i],"_Stack_Extr.tif", "_"+source2+"to"+source1+"_Reg.tif"))))	{
			DestinationFilePath=replace(inDir+s+list[i], inDir, outDir);
			open(inDir+list[i]);
			name=File.getName(inDir+list[i]);
			selectWindow(name);
			width=getWidth();
			height=getHeight();
			rename("source");
			if (AVG=="AVG Complete") {
				run("Z Project...", "projection=[Average Intensity]");
			}
			else if (AVG=="AVG Selection") {
				run("Z Project...", "start="+AVGStart+" stop="+AVGStop+" projection=[Average Intensity]");
			}
			selectWindow("AVG_source");
			rename("target");
			run("Split Channels");
			close(target2+"-target");			
			selectWindow("source");
			run("Split Channels");			
			sln=nSlices;			
			for(k=1; k <=sln; k++) {
				selectWindow(source1+"-source");
				run("Duplicate...", "title="+source1+"-currentFrame duplicate range="+k+"");
				selectWindow(source2+"-source");
				run("Duplicate...", "title="+source2+"-currentFrame duplicate range="+k+"");				
				run("TurboReg ", "-align "+"-window "+source1+"-currentFrame 0 0 "+(width - 1)+" " +(height - 1)+" "+"-window "+target1+"-target 0 0 "+(width - 1)+" "+(height - 1) +" -rigidBody "+(width / 2)+" "+(height / 2)+" "+ (width / 2) + " " + (height / 2) + " "+ "0 " + (height / 2) + " 0 "+(height / 2)+" "+(width - 1)+" "+(height / 2)+" "+(width - 1)+" "+(height / 2)+" -showOutput");
				SX1=getResult("sourceX", 0);
				SY1=getResult("sourceY", 0);
				TX1=getResult("targetX", 0);
				TY1=getResult("targetY", 0);
				SX2=getResult("sourceX", 1);
				SY2=getResult("sourceY", 1);
				TX2=getResult("targetX", 1);
				TY2=getResult("targetY", 1);
				SX3=getResult("sourceX", 2);
				SY3=getResult("sourceY", 2);
				TX3=getResult("targetX", 2);
				TY3=getResult("targetY", 2);
				selectWindow("Output");
				resetMinAndMax();
				run("Duplicate...", "title="+source1+"-registered");
				close("Output");
				run("TurboReg ", "-transform -window "+source2+"-currentFrame "+(width)+" "+(height)+" -rigidBody "+SX1+" "+SY1+" "+TX1+ " "+TY1+" "+SX2+" "+SY2+" "+TX2+" "+TY2+" "+SX3+" "+SY3+" "+TX3+" "+TY3+" -showOutput");
				selectWindow("Output");
				resetMinAndMax();
				run("Duplicate...", "title="+source2+"-registered");
				close("Output");						
				if(k==1) {
					selectWindow(source2+"-registered");
					run("Duplicate...", "title="+source2+"-regstack");
					selectWindow(source1+"-registered");
					run("Duplicate...", "title="+source1+"-regstack");
					close(source2+"-registered");
					close(source1+"-registered");
				}
				else {
					run("Concatenate...", "  title="+source2+"-regstack" + " image1="+source2+"-regstack" + " image2="+source2+"-registered image3=[-- None --] image4=[-- None --]");
					run("Concatenate...", "  title="+source1+"-regstack" + " image1="+source1+"-regstack" + " image2="+source1+"-registered image3=[-- None --] image4=[-- None --]");
				}
				close(source1+"-currentFrame");
				close(source2+"-currentFrame");
				close(source1+"-registered");
				close(source2+"-registered");
			}
			run("Merge Channels...", "c1=C1-regstack c2=C2-regstack create");
			selectWindow("regstack");
			Stack.setDisplayMode("grayscale");
			Stack.setChannel(1);
			resetMinAndMax();
			Stack.setChannel(2);
			resetMinAndMax();
			saveAs("tiff", replace(DestinationFilePath, "_Stack_Extr.tif", "_"+source2+"to"+source1+"_Reg.tif"));	
			run("Close All");
			close("Refined Landmarks");	
			run("Collect Garbage");
			close("Log");
		}
	}
}
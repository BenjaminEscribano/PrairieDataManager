s=File.separator;

Dialog.create("Bruker Data Manager");
Dialog.addMessage("Delete Files:");
items=newArray("_Stack_Extr.tif", "_SReg.tif", "_C1_Reg.tif", "_C2_Reg.tif", "_C1toC2_Reg.tif", "_C2toC1_Reg.tif", "_BSub.tif", "_RoiSet.zip", "_MeanGray.csv", "_DeltaF.tif", "_DeltaFHeatMap.tif", "_Spl.tif");
Dialog.addChoice("File Identifier:", items, "C1_Reg.tif");

Dialog.show();

DelFileIdent=Dialog.getChoice();


showMessageWithCancel("CAUTION!!","Are you sure that you want to delete all the "+DelFileIdent+" ending files?")


inDir=getDirectory("Choose target folder:");

DeleteFiles(inDir);

print("Done!");

function DeleteFiles(inDir) {
	list = getFileList(inDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/")) {
			DeleteFiles(inDir+list[i]);
		}
		else if (endsWith(list[i], DelFileIdent)) {
			File.delete(inDir+list[i])		
		}					
	}
}
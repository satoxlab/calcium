arg  = getArgument();
args = split(arg, ":");

dir = args[0];
// eachDirectory  = split(dir, "/");
// outputFileName = eachDirectory[eachDirectory.length] + ".tif";
dir = dir + "/";

newImageName     = args[1];

setBatchMode(true)

file_list  = getFileList(dir);
stackArray = newArray(file_list.length);
newImage(newImageName, "32-bit", 512, 512, file_list.length);
stackID = getImageID;

for (i=0; i<file_list.length; i++) {
    infile  = dir + file_list[i];
    run("Text Image... ", "open=["+infile+"]");
    sliceID = getImageID;
    run("Copy");
    selectImage(sliceID);
    close();
    selectImage(stackID);
    setSlice(i+1);
    run("Paste");
}


selectImage(stackID);
run("Save", "save="+newImageName);
run("Close");

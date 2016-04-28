arg  = getArgument();
args = split(arg, ":");
dir        = args[0];
output_dir = args[1];

function formatDigits(i){
    if (i < 1000){
        if (i < 100){
            if (i < 10){
                i = "000" + i;
            }
        }
        else{
            i = "00" + i;
        }
    }
    else{
        i = "0" + i;
    }

    return (i);
}

File.makeDirectory(output_dir);
input_files = getFileList(dir);

for (i=0; i<= input_files.length-1; i++){
    input_file = input_files[i];
    open (dir + input_file);
    outputFileName = replace(input_file, ".tif", ".txt"); 
    saveAs("Text Image", output_dir + outputFileName);
}


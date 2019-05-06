 showMessage("Institue for Molecular Biosciences ImageJ Script", "<html>" 
     +"<h1><font <size=4> <color=teal><i>ACRF: Cancer Biology Imaging Facility</i></h1>
     +"<h2><font color=Purple><i>The University of Queensland</i></h2>
     +"<h1><font color=black>ImageJ Script Macro: Aurelie Dot Measuring/Counting Script</h1> "
     +"<h1><font size=2>Created by Nicholas Condon 2018 	(n.condon@uq.edu.au)</h1>"
     +"<h1><font size=2><colour=blue><i>This script takes dual channel images from the IMB Zeiss Spinning disc confoal and flattens them by sum projection. It then measures 'red dots' and asks if they are green dots.</h1>");


path = getDirectory("Choose Source Directory ");
list = getFileList(path);
//setBatchMode(true);
resultsDir = path+"Results/";
File.makeDirectory(resultsDir);

summaryFile = File.open(resultsDir+"Results.xls");
print(summaryFile,"Image\t Cell \t Count \t Red Intensity");
run("Clear Results");
start = getTime();
for (i=0; i<list.length; i++) {
if (endsWith(list[i],".tif")){
  		
  		open(path+list[i]);
  		run("Z Project...", "projection=[Max Intensity]");
  		windowtitle = getTitle();
  		run("Make Composite");
   		run("Split Channels");
  		run("Clear Results");

	selectWindow("C2-"+windowtitle);
		rename("Green");
	selectWindow("C1-"+windowtitle);
  		rename("Red");
	selectWindow("Red");
  		run("Subtract Background...", "rolling=10");
  		run("Find Maxima...", "noise=1000 output=[Single Points]");
  			rename("Points");
  		setOption("BlackBackground", false);
  		run("Dilate");
  		run("Set Measurements...", "mean redirect=None decimal=3");
  		run("Analyze Particles...", "exclude add");
  		selectWindow("Red");
  		roiManager("multi-measure measure_all");

	redi=newArray(nResults);
for (r=0; r<nResults();r++){
		redi[r] = getResult("Mean", r);	
		print(redi[r]);
		//r=r++;
		}
 		

 	selectWindow("Green");
 	run("Subtract Background...", "rolling=10");
 	run("Clear Results");
 	roiManager("multi-measure measure_all");
 	greeni=newArray(nResults);
 		for (g=0; g<nResults();g++){
				greeni[g] = getResult("Mean", g);	
				print(greeni[g]);
				//g=g++;
 		}
  
    
  for (j=0 ; j<nResults ; j++) {  
    Red = redi[j];
    Green = getResult("Mean",j);
    Label = j;
    Cell =i;
    print(summaryFile,windowtitle+"\t"+Cell+"\t"+Label+"\t"+Green+"\t=IF(D"+j+2+"<500, 0, 1)");
  	   }  
}
  run("Clear Results");


//Section 6
//Outputing results files into subdirectory called 'Results.' The script will close and clear all relevant
//information before moving onto the next file in the list, until finished.
 // saveAs("Results", resultsDir+ windowtitle + "Results.csv");
  selectWindow("Red");
  saveAs("Tiff", resultsDir+ windowtitle + "Red.tif");
 close();
  selectWindow("Green");
  saveAs("Tiff", resultsDir+ windowtitle + "Green.tif");
  close();
// run("Merge Channels...", "c1=red c2=green create ignore");
// saveAs("Tiff", resultsDir+ windowtitle + "merge.tif");
 selectWindow("Points");
  saveAs("Tiff", resultsDir+ windowtitle + "Points.tif");
  close();  
  close();  
  roiManager("Save", resultsDir+ windowtitle + "RoiSet.zip");
  run("Clear Results");
  selectWindow("ROI Manager");
  roiManager("Delete");
}

print("Total Runtime was:");
print((getTime()-start)/1000); 

title = "Batch Completed";
msg = "Put down that coffee! Your analysis is finished";
waitForUser(title, msg);          

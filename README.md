# zitome
Read and re-shuffle OME-TIF files from 2-channel recordings into a single OME-TIF file with interleaved pages.

## Usage

The script operates on a single folder containing a pair of ome.tif files from the Bruker. I have assumed the
following is true of the folder:
* An XML file exists in this folder with the same basename as the folder. If the folder is 'ds0345a-001', then there should be an XML file named 'ds0345a-001.xml'. If the file has a different name (e.g. the xml file does not match the folder name), then the xmlfilename can be passed on the command line.
* There are only two channels, and the filename is taken from the attributes of the XML tag 'PVScan.Sequence.Frame.File'. We find the first such tag with a 'channel' attribute of '1' ('2'), and use its 'filename' attribute to for the Channel 1 (2) images.
* I assume the two channel TIF files have the same number of images. If the two files have a different number of images, the script will fail.

The simplest case - data in a folder in my home dir:
 > newfile = mergeCh12('/home/dan/work/zito/ds0345-c/ds0345a-001');

 
 
 > newfile = mergeCh12('/home/dan/work/zito/ds0345-c/ds0345a-001');
 > newfile = mergeCh12('/home/dan/work/zito/ds0345-c/ds0345a-001');
 > newfile = mergeCh12('/home/dan/work/zito/ds0345-c/ds0345a-001');
 > newfile = mergeCh12('/home/dan/work/zito/ds0345-c/ds0345a-001');
